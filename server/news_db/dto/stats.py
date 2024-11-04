from typing import Dict

from pydantic import BaseModel


class StatsDTO(BaseModel):
    articleTitle: str
    wordsCount: int
    histogram: Dict[str, int]
