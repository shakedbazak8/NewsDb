from pydantic import BaseModel

from news_db.model.index_type import IndexType


class IndexDTO(BaseModel):
    index: str
    line: int
    paragraph: int
    type: IndexType
