from pydantic import BaseModel

from model.index_type import IndexType


class Index(BaseModel):
    file_id: int
    index: str
    line: int
    id: int
    paragraph: int
    type: IndexType
