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

    def is_empty(self):
        return not bool(self.publishDate) and not bool(self.page) and not bool(self.author) and not bool(self.title) and not bool(self.subject) and not bool(self.paperName)
