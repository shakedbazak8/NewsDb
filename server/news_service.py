from fastapi import UploadFile

from dto.article import ArticleDTO
from fs.base import BaseFs
from model.article import Article


class NewsService:

    def __init__(self, fs: BaseFs):
        self._fs = fs

    async def upload_file(self, file: UploadFile, article_dto: ArticleDTO) -> bool:
        try:
            data = await file.read()
            path = self._fs.store(data.decode())
            raw_article = article_dto.dict()
            raw_article.update({'filePath': path, 'wordNum': len(data)})
            article = Article(**raw_article)
            print(article)
            return True
        except Exception as e:
            print(e)
            return False

