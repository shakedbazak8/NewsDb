import uuid
from datetime import date

from pydantic import BaseModel


class Article(BaseModel):
    id: str = str(uuid.uuid4())
    publishDate: date
    page: int
    author: str
    title: str
    subject: str
    paperName: str
    filePath: str
    wordNum: int
