from pydantic import BaseModel

from model.index_type import IndexType


class IndexDTO(BaseModel):
    index: str
    line: int
    paragraph: int
    type: IndexType
