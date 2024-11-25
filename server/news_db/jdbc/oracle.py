from itertools import groupby
from typing import List, Dict, Any, Optional

import oracledb

from news_db.dto.article import ArticleDTO
from news_db.dto.index import IndexDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.jdbc.base import BaseJdbc
from news_db.model.article import Article
from news_db.model.index import Index
from news_db.model.index_type import IndexType
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup


class OracleJdbc(BaseJdbc):

    def __init__(self, dsn: str, user: str, password: str):
        self._connection = oracledb.connect(dsn=dsn, user=user, password=password)

    def transaction(self, statements) -> bool:
        try:
            with self._connection.cursor() as cursor:
                for statement in statements:
                    statement(cursor)
                self._connection.commit()
                return True
        except:
            self._connection.rollback()
            return False

    def fetch(self, article: Article) -> Article:
        pass

    def insert(self, article: Article) -> bool:
        sql = f"""INSERT INTO articles (id, publish_date, page, author, title, subject, paper_name, file_path, word_num) VALUES ('{article.id}', TO_DATE('{article.publishDate}', 'YYYY-MM-DD'), {article.page}, '{article.author}', '{article.title}', '{article.subject}', '{article.paperName}', '{article.filePath}', {article.wordNum})"""
        try:
            with self._connection.cursor() as cursor:
                print(sql)
                cursor.execute(sql)
            self._connection.commit()
            return True
        except:
            return False

    def find_all(self, article: ArticleDTO) -> List[Article]:
        sql = f"""SELECT articles.* from articles {self._build_where_clause(article)}"""
        print(sql)
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = self._fetch_article_as_dict(cursor)
            return [Article(**row) for row in rows]

    def find_all_by_name(self, title: str) -> List[Article]:
        sql = f"""SELECT articles.* from articles where title = '{title}'"""
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = self._fetch_article_as_dict(cursor)
            return [Article(**row) for row in rows]

    def find_all_by_words(self, words: List[str]) -> List[Article]:
        if words:
            sql = f"""
    SELECT distinct articles.*
    FROM indices
    INNER JOIN articles ON articles.id = indices.article_id
    WHERE TYPE = 'word' AND term IN ({', '.join(f"'{word}'" for word in words if bool(word))})
"""
            with self._connection.cursor() as cursor:
                print(sql)
                cursor.execute(sql)
                rows = self._fetch_article_as_dict(cursor)
                return [Article(**row) for row in rows]
        return []

    def _build_where_clause(self, article: ArticleDTO) -> str:
        raw = article.dict() if article else {}
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
        return where_clause

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

    def store_indices(self, indices: List[Index]) -> bool:
        try:
            word_indices = list(filter(lambda x: x.type == IndexType.WORD, indices))
            words = []
            groups = []
            phrases = []
            for idx in word_indices:
                words.append(
                    {'article_id': idx.article_id, 'term': idx.index, 'line': idx.line, 'paragraph': idx.paragraph})
            group_indices = list(filter(lambda x: x.type == IndexType.GROUP, indices))
            for idx in group_indices:
                groups.append(
                    {'article_id': idx.article_id, 'term': idx.index, 'line': idx.line, 'paragraph': idx.paragraph})
            phrase_indices = list(filter(lambda x: x.type == IndexType.PHRASE, indices))
            for idx in phrase_indices:
                phrases.append(
                    {'article_id': idx.article_id, 'term': idx.index, 'line': idx.line, 'paragraph': idx.paragraph})
            word_sql = """INSERT INTO indices (article_id, term, line, paragraph, type) VALUES (:article_id, :term, :line, :paragraph, 'word')"""
            group_sql = """INSERT INTO indices (article_id, term, line, paragraph, type) VALUES (:article_id, :term, :line, :paragraph, 'group')"""
            phrase_sql = """INSERT INTO indices (article_id, term, line, paragraph, type) VALUES (:article_id, :term, :line, :paragraph, 'phrase')"""
            with self._connection.cursor() as cursor:
                cursor.executemany(word_sql, words)
                if groups:
                    cursor.executemany(group_sql, groups)
                if phrases:
                    cursor.executemany(phrase_sql, phrases)
            self._connection.commit()
            return True
        except Exception as e:
            print(e)
            return False

    def get_words(self, article: Optional[ArticleDTO] = None) -> List[str]:
        where_clause = self._build_where_clause(article)
        sql = f"""
        WITH article_ids AS (
            SELECT id FROM articles
            {where_clause}
        ) 
        SELECT DISTINCT indices.term FROM indices
        INNER JOIN article_ids ON article_ids.id = indices.article_id
        WHERE TYPE = 'word'
        """
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            return [l[0] for l in cursor.fetchall()]


    def get_by_index(self, index: IndexDTO, articles: List[str]) -> List[str]:
        mapping = {IndexType.WORD: 'word', IndexType.GROUP: 'group', IndexType.PHRASE: 'phrase'}
        where_clause = f"WHERE type = '{mapping[index.type]}' AND line = {index.line} AND paragraph = {index.paragraph}"
        articles = [f"'{a}'" for a in articles]
        if articles:
            where = f"where title IN ({','.join(articles)})"
            sql = f"""
            WITH article_ids AS (
                SELECT id FROM articles
                {where}
            ) 
            SELECT indices.term FROM indices
            INNER JOIN article_ids ON article_ids.id = indices.article_id
            {where_clause}
        """
        else:
            sql = f"""
                SELECT indices.term FROM indices
                {where_clause} 
            """
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            return [l[0] for l in cursor.fetchall()]

    def basic_stats(self) -> List[Dict[str, Any]]:
        sql = """
        SELECT
            sum(CASE WHEN TYPE = 'word' THEN 1 ELSE 0 end) AS words,
            count(DISTINCT CASE WHEN TYPE = 'group' THEN term ELSE NULL end) AS groups,
            COUNT(DISTINCT line) AS lines,
            COUNT(DISTINCT paragraph) AS pargraphes,
            title
            FROM indices
            INNER JOIN articles ON articles.id = indices.article_id
            GROUP BY TITLE 
        """
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = ['words', 'groups', 'lines', 'paragraphs', 'title']
            return [dict(zip(columns, row)) for row in rows]

    def words_histogram(self) -> List[Dict[str, Any]]:
        sql = """
        SELECT
        count(*) AS cnt,
        title,
        term
        FROM indices
        INNER JOIN articles ON articles.id = indices.article_id
        WHERE TYPE = 'word'
        GROUP BY TITLE, term 
        """
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = ['cnt', 'title', 'term']
            return [dict(zip(columns, row)) for row in rows]

    def group_histogram(self) -> List[Dict[str, Any]]:
        sql = """
        SELECT
        count(*) AS cnt,
        title,
        term
        FROM indices
        INNER JOIN articles ON articles.id = indices.article_id
        WHERE TYPE = 'group'
        GROUP BY TITLE, term 
        """
        with self._connection.cursor() as cursor:
            cursor.execute(sql)
            rows = cursor.fetchall()
            columns = ['cnt', 'title', 'term']
            return [dict(zip(columns, row)) for row in rows]

    def get_all_articles(self) -> List[Article]:
        with self._connection.cursor() as cursor:
            cursor.execute("select * from articles")
            raw = self._fetch_article_as_dict(cursor)
            return [Article(**row) for row in raw]

    def get_all_indices(self) -> List[Index]:
        with self._connection.cursor() as cursor:
            cursor.execute("select * from indices")
            columns = ['article_id', 'index', 'line', 'id', 'paragraph', 'type']
            rows = cursor.fetchall()
            raw = [dict(zip(columns, row)) for row in rows]
            mapping = {'word': IndexType.WORD, 'group': IndexType.GROUP, 'phrase': IndexType.PHRASE}
            for row in raw:
                row['type'] = mapping[row['type']]
            return [Index(**row) for row in raw]

    def get_all_groups(self) -> List[WordGroup]:
        with self._connection.cursor() as cursor:
            cursor.execute("select * from groups")
            columns = ['name', 'word']
            rows = cursor.fetchall()
            raw = [dict(zip(columns, row)) for row in rows]
            grouped = {key: list(group) for key, group in groupby(raw, key=lambda x: x['name'])}
            groups = {}
            for group in grouped:
                groups.update({'name': group, 'words': [r['word'] for r in grouped[group]]})
            print(groups)
            return [WordGroup(**groups) for group in groups]

    def get_all_phrases(self) -> List[Phrase]:
        with self._connection.cursor() as cursor:
            cursor.execute("select * from phrases")
            columns = ['phrase', 'definition']
            rows = cursor.fetchall()
            raw = [dict(zip(columns, row)) for row in rows]
            return [Phrase(**row) for row in raw]

    def insert_all_articles(self, articles: List[Article]) -> bool:
        try:
            with self._connection.cursor() as cursor:
                articles = [article.dict() for article in articles]
                sql = """INSERT INTO articles (id, publish_date, page, author, title, subject, paper_name, file_path, word_num) VALUES (:id, TO_DATE(:publishDate, 'YYYY-MM-DD'), :page, :author, :title, :subject, :paperName, :filePath, :wordNum)"""
                cursor.executemany(sql, articles)
                self._connection.commit()
                return True
        except Exception as e:
            return False

    def insert_all_indices(self, indices: List[Index]) -> bool:
        indices = [index.dict() for index in indices]
        mapping = {IndexType.WORD: 'word', IndexType.GROUP: 'group', IndexType.PHRASE: 'phrase'}
        for index in indices:
            index['index_type'] = mapping[index['type']]
            del index['type']
            index['term'] = index['index']
            del index['index']

        try:
            with self._connection.cursor() as cursor:
                sql = """INSERT INTO indices (article_id, term, line, paragraph, type, id) VALUES (:article_id, :term, :line, :paragraph, :index_type, :id)"""
                cursor.executemany(sql, indices)
                self._connection.commit()
                return True
        except Exception as e:
            return False

    def insert_all_groups(self, groups: List[WordGroup]) -> bool:
        groups = [group.dict() for group in groups]
        wg = []
        for group in groups:
            for word in group['words']:
                wg.append({'group_name': group['name'], 'word': word})
        try:
            with self._connection.cursor() as cursor:
                sql = """INSERT INTO groups (name, word) VALUES (:group_name, :word)"""
                cursor.executemany(sql, wg)
                self._connection.commit()
                return True
        except Exception as e:
            return False

    def insert_all_phrases(self, phrases: List[Phrase]) -> bool:
        try:
            with self._connection.cursor() as cursor:
                sql = f"""INSERT INTO phrases (phrase, definition) VALUES (:phrase, :definition)"""
                cursor.executemany(sql, [phrase.dict() for phrase in phrases])
                self._connection.commit()
                return True
        except Exception as e:
            return False
