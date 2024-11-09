from news_db.fs.local import LocalFs
from news_db.jdbc.oracle import OracleJdbc
from news_db.news_service import NewsService
from news_db import config

class Bootstrap:

    def start(self) -> NewsService:
        return NewsService(LocalFs(config.BASE_DIR), OracleJdbc(config.ORACLE_DSN, config.ORACLE_USER, config.ORACLE_PASS))