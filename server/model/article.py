from pydantic import BaseModel
from datetime import date


class Article(BaseModel):
    publish_date: date
    page: int
    author: str
    title: str
    subject: str
    id: int
    paper_name: str
    file_path: str
    word_num: int
