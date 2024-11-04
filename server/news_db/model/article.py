from pydantic import BaseModel
from datetime import date


class Article(BaseModel):
    publishDate: date
    page: int
    author: str
    title: str
    subject: str
    paperName: str
    filePath: str
    wordNum: int
