from typing import Optional

from pydantic import BaseModel


class WordGroupDTO(BaseModel):
    name: Optional[str]