from typing import Optional

from pydantic_xml import BaseXmlModel, attr

from news_db.model.index_type import IndexType


class Index(BaseXmlModel):
    article_id: str = attr()
    index: str = attr()
    line: int = attr()
    id: Optional[int] = attr(default=None)
    paragraph: int = attr()
    type: IndexType = attr()
