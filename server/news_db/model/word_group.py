from typing import List

from pydantic_xml import BaseXmlModel, attr, element


class WordGroup(BaseXmlModel):
    name: str = attr()
    words: List[str] = element()