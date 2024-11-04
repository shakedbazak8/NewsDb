from jdbc.abstract import AbstractJdbc
from model.article import Article


class OracleJdbc(AbstractJdbc):

    def fetch(self, article: Article) -> Article:
        pass