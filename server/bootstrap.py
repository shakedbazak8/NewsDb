from fs.local import LocalFs
from news_service import NewsService


class Bootstrap:

    def start(self) -> NewsService:
        return NewsService(LocalFs())