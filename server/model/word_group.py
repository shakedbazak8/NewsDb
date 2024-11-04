from typing import List

from pydantic import BaseModel


class WordGroup(BaseModel):
    name: str
    words: List[str]