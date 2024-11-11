from pydantic import BaseModel

from news_db.model.index_type import IndexType


class Index(BaseModel):
    article_id: str
    index: str
    line: int
    id: int
    paragraph: int
    type: IndexType
