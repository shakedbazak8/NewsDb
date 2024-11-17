from typing import List

from pydantic_xml import BaseXmlModel, element

from news_db.model.article import Article
from news_db.model.index import Index
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup


class Db(BaseXmlModel):
    articles: List[Article] = element()
    indices: List[Index] = element()
    groups: List[WordGroup] = element()
    phrases: List[Phrase] = element()