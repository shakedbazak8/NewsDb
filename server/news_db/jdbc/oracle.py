from typing import List

import oracledb

from news_db.dto.article import ArticleDTO
from news_db.jdbc.base import BaseJdbc
from news_db.model.article import Article


class OracleJdbc(BaseJdbc):

    def __init__(self, dsn: str, user: str, password: str):
        self._connection = oracledb.connect(dsn=dsn, user=user, password=password)

    def transaction(self, statements: List[str]) -> bool:
        try:
            with self._connection.cursor() as cursor:
                for statement in statements:
                    cursor.execute(statement)
                self._connection.commit()
                return True
        except:
            self._connection.rollback()
            return False

    def fetch(self, article: Article) -> Article:
        pass

    def insert(self, article: Article) -> str:
        return f"""INSERT INTO articles (id, publish_date, page, author, title, subject, paper_name, file_path, word_num) VALUES ('{article.id}', TO_DATE('{article.publishDate}', 'YYYY-MM-DD'), {article.page}, '{article.author}', '{article.title}', '{article.subject}', '{article.paperName}', '{article.filePath}', {article.wordNum})"""

    def find_all(self, article: ArticleDTO) -> List[Article]:
        raw = article.dict()
        terms = []
        for key in raw:
            if raw[key]:
                terms.append(f"{key} = {raw[key]}" if isinstance(raw[key], int) else f"{key} = '{raw[key]}'")
        if terms:
            if len(terms) == 1:
                where_clause = f"WHERE {terms[0]}"
            else:
                where_clause = f"WHERE " + ' AND '.join(terms)
        else:
            where_clause = ''
        sql = f"""SELECT articles.* from articles {where_clause}"""
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = self._fetch_article_as_dict(cursor)
            return [Article(**row) for row in rows]


    def find_all_by_words(self, words: List[str]) -> List[Article]:
        return []

    def _fetch_article_as_dict(self, cursor):
        rows = cursor.fetchall()
        columns = ['id', 'publishDate', 'page', 'author', 'title', 'subject', 'paperName', 'filePath', 'wordNum']
        result = [dict(zip(columns, row)) for row in rows]
        return result
