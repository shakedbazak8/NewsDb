from typing import Optional

from pydantic import BaseModel

from news_db.model.index_type import IndexType


class IndexDTO(BaseModel):
    index: Optional[str] = None
    line: int
    paragraph: int
    type: IndexType
