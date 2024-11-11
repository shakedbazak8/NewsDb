import uuid
from typing import List

from fastapi import UploadFile

from news_db.dto.article import ArticleDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.fs.base import BaseFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.model.article import Article
from news_db.model.word_group import WordGroup
from news_db.utils.word import extract_words


class NewsService:

    def __init__(self, fs: BaseFs, repository: OracleJdbc):
        self._fs = fs
        self._repository = repository

    async def upload_file(self, file: UploadFile, article_dto: ArticleDTO) -> bool:
        try:
            data = (await file.read()).decode()
            words = extract_words(data)
            path = self._fs.store(data)
            raw_article = article_dto.dict()
            raw_article.update({'filePath': path, 'wordNum': len(words)})
            article = Article(**raw_article) # TODO: store indexes.
            return self._repository.transaction([self._repository.insert(article)])
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