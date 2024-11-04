from datetime import date

from pydantic import BaseModel


class ArticleDTO(BaseModel):
    publishDate: date
    page: int
    author: str
    title: str
    subject: str
    paperName: str
