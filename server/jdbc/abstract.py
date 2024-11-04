from abc import ABC, abstractmethod

from model.article import Article


class AbstractJdbc(ABC):

    @abstractmethod
    def fetch(self, article: Article) -> Article:
        pass