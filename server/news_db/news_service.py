import uuid

from fastapi import UploadFile

from news_db.dto.article import ArticleDTO
from news_db.fs.base import BaseFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.model.article import Article


class NewsService:

    def __init__(self, fs: BaseFs, repository: OracleJdbc):
        self._fs = fs
        self._repository = repository

    async def upload_file(self, file: UploadFile, article_dto: ArticleDTO) -> bool:
        try:
            data = await file.read()
            path = self._fs.store(data.decode())
            raw_article = article_dto.dict()
            raw_article.update({'filePath': path, 'wordNum': len(data)})
            article = Article(**raw_article)
            return self._repository.insert(article)
        except Exception as e:
            print(e)
            return False

