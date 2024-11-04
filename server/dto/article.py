from typing import Optional

from pydantic import BaseModel
from datetime import date


class ArticleDTO(BaseModel):
    publishDate: Optional[date]
    page: Optional[int]
    author: Optional[str]
    title: Optional[str]
    subject: Optional[str]
    paperName: Optional[str]
    filePath: Optional[str]
