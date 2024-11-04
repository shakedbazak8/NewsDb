from news_db.jdbc.base import BaseJdbc
from news_db.model.article import Article


class OracleJdbc(BaseJdbc):

    def fetch(self, article: Article) -> Article:
        pass