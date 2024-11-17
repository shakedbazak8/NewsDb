from datetime import date
from typing import Optional
from pydantic_xml import BaseXmlModel, attr


class Article(BaseXmlModel):
    id: Optional[str] = attr(default=None)
    publishDate: date = attr()
    page: int = attr()
    author: str = attr()
    title: str = attr()
    subject: str = attr()
    paperName: str = attr()
    filePath: str = attr()
    wordNum: int = attr()
