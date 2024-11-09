from datetime import date
from typing import Optional

from pydantic import BaseModel


class ArticleDTO(BaseModel):
    publishDate: Optional[date] = None
    page: int
    author: str
    title: str
    subject: str
    paperName: str
