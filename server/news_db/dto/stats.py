from typing import Dict, List, Any

from pydantic import BaseModel


class StatsDTO(BaseModel):
    title: str
    words: int
    groups: int
    lines: int
    paragraphs: int
    groups_histogram: List[Dict[str, Any]]
    words_histogram: List[Dict[str, Any]]
