import json
from collections import defaultdict
from datetime import date
from typing import List, Optional

from fastapi import FastAPI, UploadFile, File, Form

from news_db.bootstrap import Bootstrap
from news_db.dto.article import ArticleDTO
from news_db.dto.index import IndexDTO
from news_db.dto.stats import StatsDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.dto.xml import XmlDTO
from news_db.model.article import Article
from news_db.model.index_type import IndexType
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup

app = FastAPI()
service = Bootstrap().start()


@app.get("/")
async def index() -> str:
    return "Hello"


@app.post("/export-db")
async def export_db(xml_dto: XmlDTO) -> bool:
    # TODO
    print(xml_dto.dbName)
    return True


@app.post("/import-db")
async def import_db(xml_dto: XmlDTO) -> bool:
    # TODO
    print(xml_dto.dbName)
    return True

@app.post("/articles")
async def upload(file: UploadFile = File(...), article: str = Form(...)) -> bool:
    try:
        raw = json.loads(article)
        article_dto = ArticleDTO(**raw)
        return await service.upload_file(file, article_dto)
    except Exception as e:
        raise e



@app.get("/articles")
async def get_articles(publishDate: Optional[date] = None, page: Optional[int] = 0, author: Optional[str] = '',
                       title: Optional[str] = '', subject: Optional[str] = '', paperName: Optional[str] = '',
                       words: Optional[str] = '') -> List[Article]:
    word_list = words.split(',')
    dto_raw = {'publishDate': publishDate, 'page': page, 'author': author, 'title': title, 'subject': subject,
               'paperName': paperName}
    dto = ArticleDTO(**dto_raw) # TODO: words.
    return await service.get_articles(dto, word_list)


@app.get("/words")
async def get_words(publishDate: Optional[date] = None, page: Optional[int] = 0, author: Optional[str] = '',
                       title: Optional[str] = '', subject: Optional[str] = '', paperName: Optional[str] = '') -> List[str]:
    dto_raw = {'publishDate': publishDate, 'page': page, 'author': author, 'title': title, 'subject': subject,
               'paperName': paperName}
    dto = ArticleDTO(**dto_raw)
    return await service.get_words(dto)


@app.get("/index")
async def get_by_index(paragraph: int, line: int, index_type: str, articles: str) -> List[str]:
    articles = list(filter(lambda x: bool(x), articles.split(";")))
    mapping = defaultdict(lambda: IndexType.WORD)
    mapping['group'] = IndexType.GROUP
    mapping['phrase'] = IndexType.PHRASE
    dto = IndexDTO(**{'paragraph': paragraph, 'line': line, 'type': mapping[index_type]})
    return await service.get_by_index(dto, articles)


@app.post("/groups")
async def create_word_group(word_group: WordGroup) -> bool:
    return await service.create_group(word_group)


@app.put("/groups")
async def update_word_group(word_group: WordGroup) -> bool:
    dto = WordGroupDTO(**{'name': word_group.name})
    groups = await service.get_groups(dto)
    group = groups[0] if groups else None
    print(group)
    if group:
        update_group = WordGroup(**{'name': word_group.name, 'words': list(set(word_group.words) - set(group.words))})
        return await service.create_group(update_group)
    else:
        return await service.create_group(word_group)


@app.get("/groups")
async def get_word_groups(name: Optional[str] = None) -> List[WordGroup]:
    dto = WordGroupDTO(**{'name': name})
    return await service.get_groups(dto)


@app.post("/phrases")
async def create_phrase(phrase: Phrase) -> bool:
    return await service.create_phrase(phrase)


@app.get("/phrases")
async def get_phrases() -> List[Phrase]:
    # TODO
    return await service.get_phrases()


@app.get("/stats")
async def get_stats() -> List[StatsDTO]:
    return []
