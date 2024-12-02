import hashlib
import uuid
from collections import defaultdict
from itertools import groupby
from typing import List, Optional

from fastapi import UploadFile

from news_db.dto.article import ArticleDTO
from news_db.dto.index import IndexDTO
from news_db.dto.stats import StatsDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.fs.base import BaseFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.model.article import Article
from news_db.model.db import Db
from news_db.model.index import Index
from news_db.model.index_type import IndexType
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup
from news_db.utils.index import get_word_index, get_phrase_indexes, get_group_indexes, get_preview
from news_db.xml import Xml


class NewsService:

    def __init__(self, fs: BaseFs, repository: OracleJdbc, xml: Xml):
        self._fs = fs
        self._repository = repository
        self._xml = xml

    async def upload_file(self, file: UploadFile, article_dto: ArticleDTO) -> bool:
        try:
            data = (await file.read()).decode()
            words = get_word_index(data)
            article_id = str(uuid.uuid4())
            word_indices = [word.dict() for word in words]
            for word_index in word_indices:
                word_index['article_id'] = article_id
                word_index['type'] = IndexType.WORD
            word_indices = [Index(**raw) for raw in word_indices]
            groups = get_group_indexes(data, self._repository.get_groups(WordGroupDTO(name=None)))
            group_indices = [group.dict() for group in groups]
            for group_index in group_indices:
                group_index['article_id'] = article_id
                group_index['type'] = IndexType.GROUP
            group_indices = [Index(**raw) for raw in group_indices]
            phrases = get_phrase_indexes(data, self._repository.get_phrases())
            phrase_indices = [phrase.dict() for phrase in phrases]
            for phrase_index in phrase_indices:
                phrase_index['article_id'] = article_id
                phrase_index['type'] = IndexType.PHRASE
            phrase_indices = [Index(**raw) for raw in phrase_indices]
            path = self._fs.store(data)
            raw_article = article_dto.dict()
            raw_article.update({'filePath': path, 'wordNum': len(words), 'id': article_id})
            article = Article(**raw_article)
            uploaded = self._repository.insert(article)
            return self._repository.store_indices(word_indices + group_indices + phrase_indices) and uploaded
        except Exception as e:
            raise e

    async def get_articles(self, article_dto: ArticleDTO, words: List[str]) -> List[Article]:
        words = [word for word in words if bool(word)]
        metadata_articles = self._repository.find_all(article_dto)
        words_articles = self._repository.find_all_by_words(words)
        if article_dto.is_empty() and bool(words):
            return words_articles
        else:
            return metadata_articles + [article for article in words_articles if article not in metadata_articles]

    async def create_group(self, group: WordGroup) -> bool:
        articles = self._repository.find_all_by_words(group.words)
        for article in articles:
            data = self._fs.fetch(article.filePath)
            group_indices = get_group_indexes(data, [group])
            group_indices = [g.dict() for g in group_indices]
            for group_index in group_indices:
                group_index['article_id'] = article.id
                group_index['type'] = IndexType.GROUP
            group_indices = [Index(**raw) for raw in group_indices]
            self._repository.store_indices(group_indices)
        return self._repository.insert_group(group)

    async def get_groups(self, dto: WordGroupDTO) -> List[WordGroup]:
        return self._repository.get_groups(dto)

    async def create_phrase(self, phrase: Phrase):
        # No need to index by phrase.
        return self._repository.insert_phrase(phrase)

    async def get_phrases(self):
        return self._repository.get_phrases()

    async def get_words(self, article_dto: Optional[ArticleDTO] = None) -> List[str]:
        return self._repository.get_words(article_dto)

    async def get_by_index(self, index_dto: IndexDTO, articles: List[str]) -> List[IndexDTO]:
        indices = self._repository.get_by_index(index_dto, articles)
        return [IndexDTO(index=index.index, line=index.line, paragraph=index.paragraph, type=index.type) for index in indices]

    async def get_stats(self) -> List[StatsDTO]:
        basic_stats = self._repository.basic_stats()
        partitioned_word_histogram = defaultdict(lambda: [])
        words_histogram = self._repository.words_histogram()
        stats_words = {}
        for value in words_histogram:
            partitioned_word_histogram[value['title']].append({"term": value['term'], "cnt": value['cnt']})
        for key in partitioned_word_histogram:
            stats_words[key] = sorted(partitioned_word_histogram[key], key=lambda d: d.get("cnt"), reverse=True)
        partitioned_groups_histogram = defaultdict(lambda: [])
        groups_histogram = self._repository.group_histogram()
        stats_groups = {}
        for value in groups_histogram:
            partitioned_groups_histogram[value['title']].append({"term": value['term'], "cnt": value['cnt']})
        for key in partitioned_groups_histogram:
            stats_groups[key] = sorted(partitioned_groups_histogram[key], key=lambda d: d.get("cnt"), reverse=True)
        for stat in basic_stats:
            stat['words_histogram'] = stats_words[stat['title']] if stat['title'] in stats_words else []
            stat['groups_histogram'] = stats_groups[stat['title']] if stat['title'] in stats_groups else []
        return [StatsDTO(**raw) for raw in basic_stats]

    async def export_db(self) -> bytes:
        articles = self._repository.get_all_articles()
        indices = self._repository.get_all_indices()
        groups = self._repository.get_all_groups()
        phrases = self._repository.get_all_phrases()
        db = Db(**{'articles': articles, 'indices': indices, 'groups': groups, 'phrases': phrases})
        return self._xml.export_db(db)

    async def import_db(self, data: bytes) -> bool:
        db = self._xml.import_db(data)
        success_articles = self._repository.insert_all_articles(db.articles)
        success_indices = self._repository.insert_all_indices(db.indices)
        success_groups = self._repository.insert_all_groups(db.groups)
        success_phrases = self._repository.insert_all_phrases(db.phrases)
        return success_phrases and success_groups and success_articles and success_indices

    async def get_preview(self, article: str, line: int, paragraph: int) -> str:
        articles = self._repository.find_all_by_name(article)
        if articles:
            article = articles[0]
            return get_preview(self._fs.fetch(article.filePath), line, paragraph)
        else:
            return ""

