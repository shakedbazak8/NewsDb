from typing import List, Dict, Any

import oracledb

from news_db.dto.article import ArticleDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.jdbc.base import BaseJdbc
from news_db.model.article import Article
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup


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
        return f"""INSERT INTO articles (publish_date, page, author, title, subject, paper_name, file_path, word_num) VALUES (TO_DATE('{article.publishDate}', 'YYYY-MM-DD'), {article.page}, '{article.author}', '{article.title}', '{article.subject}', '{article.paperName}', '{article.filePath}', {article.wordNum})"""

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

    def _fetch_article_as_dict(self, cursor) -> List[Dict[str, Any]]:
        rows = cursor.fetchall()
        columns = ['id', 'publishDate', 'page', 'author', 'title', 'subject', 'paperName', 'filePath', 'wordNum']
        result = [dict(zip(columns, row)) for row in rows]
        return result

    def insert_group(self, group: WordGroup) -> bool:
        try:
            sql = f"""INSERT INTO groups (name, word) VALUES (:name, :word)"""
            data = [{'name': group.name, 'word': word} for word in group.words]
            print(data)
            with self._connection.cursor() as cursor:
                cursor.executemany(sql, data)
                self._connection.commit()
            return True
        except Exception as e:
            print(e)
            return False

    def get_groups(self, group: WordGroupDTO) -> List[WordGroup]:
        try:
            where_clause = f"WHERE name = '{group.name}'" if group.name else ""
            sql = f"""SELECT name, listagg(word, ';') as words FROM groups {where_clause} group by name"""
            print(sql)
            with self._connection.cursor() as cursor:
                cursor.execute(sql)
                rows = cursor.fetchall()
                rows = [dict(zip(['name', 'words'], row)) for row in rows]
                for row in rows:
                    row['words'] = row['words'].split(';')
                return [WordGroup(**row) for row in rows]
        except Exception as e:
            print(e)
            return []

    def insert_phrase(self, phrase: Phrase) -> bool:
        try:
            sql = f"""INSERT INTO phrases (phrase, definition) VALUES (:phrase, :definition)"""
            data = [{'phrase': phrase.phrase, 'definition': phrase.definition if phrase.definition else ''}]
            print(sql)
            with self._connection.cursor() as cursor:
                cursor.executemany(sql, data)
                self._connection.commit()
            return True
        except Exception as e:
            print(e)
            return False

    def get_phrases(self) -> List[Phrase]:
        try:
            sql = f"""SELECT * FROM phrases"""
            print(sql)
            with self._connection.cursor() as cursor:
                cursor.execute(sql)
                rows = cursor.fetchall()
                rows = [dict(zip(['phrase', 'definition'], row)) for row in rows]
                return [Phrase(**row) for row in rows]
        except Exception as e:
            print(e)
            return []