from abc import ABC, abstractmethod

from news_db.model.article import Article


class BaseJdbc(ABC):

    @abstractmethod
    def fetch(self, article: Article) -> Article:
        pass