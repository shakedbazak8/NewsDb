from abc import ABC, abstractmethod
from typing import List

from news_db.dto.article import ArticleDTO
from news_db.model.article import Article


class BaseJdbc(ABC):

    @abstractmethod
    def fetch(self, article: Article) -> Article:
        pass

    @abstractmethod
    def insert(self, article: Article) -> str:
        pass

    @abstractmethod
    def find_all(self, article: ArticleDTO) -> List[Article]:
        pass

    def find_all_by_words(self, words: List[str]) -> List[Article]:
        pass
