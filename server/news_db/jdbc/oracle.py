import oracledb

from news_db.jdbc.base import BaseJdbc
from news_db.model.article import Article


class OracleJdbc(BaseJdbc):

    def __init__(self, dsn: str, user: str, password: str):
        self._connection = oracledb.connect(dsn=dsn, user=user, password=password)

    def fetch(self, article: Article) -> Article:
        pass

    def insert(self, article: Article) -> bool:
        with self._connection.cursor() as cur:
            sql = f"""INSERT INTO articles (id, publish_date, page, author, title, subject, paper_name, file_path, word_num) VALUES ('{article.id}', TO_DATE('{article.publishDate}', 'YYYY-MM-DD'), {article.page}, '{article.author}', '{article.title}', '{article.subject}', '{article.paperName}', '{article.filePath}', {article.wordNum})"""
            print(sql)
            res = cur.execute(sql)
            self._connection.commit()
            return True
