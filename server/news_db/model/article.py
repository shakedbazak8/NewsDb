from datetime import date
from typing import Optional

from pydantic import BaseModel


class Article(BaseModel):
    id: Optional[str] = None
    publishDate: date
    page: int
    author: str
    title: str
    subject: str
    paperName: str
    filePath: str
    wordNum: int
