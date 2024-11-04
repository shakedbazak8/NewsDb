from fs.local import LocalFs
from jdbc.oracle import OracleJdbc
from news_service import NewsService


class Bootstrap:

    def start(self) -> NewsService:
        return NewsService(LocalFs(), OracleJdbc())