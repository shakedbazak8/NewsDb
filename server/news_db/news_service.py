import hashlib
import uuid
from typing import List, Optional

from fastapi import UploadFile

from news_db.dto.article import ArticleDTO
from news_db.dto.index import IndexDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.fs.base import BaseFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.model.article import Article
from news_db.model.index import Index
from news_db.model.index_type import IndexType
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup
from news_db.utils.index import extract_words_with_paragraph_and_line, get_phrase_indexes, get_group_indexes


class NewsService:

    def __init__(self, fs: BaseFs, repository: OracleJdbc):
        self._fs = fs
        self._repository = repository

    async def upload_file(self, file: UploadFile, article_dto: ArticleDTO) -> bool:
        try:
            data = (await file.read()).decode()
            words = extract_words_with_paragraph_and_line(data)
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
            print(article_id)
            raw_article.update({'filePath': path, 'wordNum': len(words), 'id': article_id})
            article = Article(**raw_article) # TODO: store indexes.
            uploaded = self._repository.insert(article)
            return self._repository.store_indices(word_indices + group_indices + phrase_indices) and uploaded
        except Exception as e:
            print(e)
            return False


    async def get_articles(self, article_dto: ArticleDTO, words: List[str]) -> List[Article]:
        return self._repository.find_all(article_dto) + self._repository.find_all_by_words(words)

    async def create_group(self, group: WordGroup) -> bool:
        #TODO: Update index
        return self._repository.insert_group(group)

    async def get_groups(self, dto: WordGroupDTO) -> List[WordGroup]:
        return self._repository.get_groups(dto)

    async def create_phrase(self, phrase: Phrase):
        # TODO: Update index
        return self._repository.insert_phrase(phrase)

    async def get_phrases(self):
        return self._repository.get_phrases()

    async def get_words(self, article_dto: Optional[ArticleDTO] = None):
        return self._repository.get_words(article_dto)

    async def get_by_index(self, index_dto: IndexDTO, articles: List[str]):
        return self._repository.get_by_index(index_dto, articles)