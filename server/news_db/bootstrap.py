from news_db.fs.local import LocalFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.news_service import NewsService


class Bootstrap:

    def start(self) -> NewsService:
        return NewsService(LocalFs(), OracleJdbc())