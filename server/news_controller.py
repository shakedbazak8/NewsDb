import json
from typing import List

from fastapi import FastAPI, UploadFile, File, Form

from bootstrap import Bootstrap
from dto.index import IndexDTO
from dto.stats import StatsDTO
from dto.xml import XmlDTO
from dto.article import ArticleDTO
from model.index_type import IndexType
from model.phrase import Phrase
from model.word_group import WordGroup

app = FastAPI()
service = Bootstrap().start()


@app.get("/")
async def index() -> str:
    return "Hello"


@app.post("/export-db")
async def export_db(xml_dto: XmlDTO) -> bool:
    print(xml_dto.dbName)
    return True


@app.post("/import-db")
async def import_db(xml_dto: XmlDTO) -> bool:
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
async def get_articles(article: ArticleDTO) -> List[ArticleDTO]:
    return []


@app.get("/words")
async def get_words(article: ArticleDTO, words: List[str]) -> List[str]:
    return []


@app.get("/index")
async def get_by_index(articles: List[str], paragraph: int, line: int, type: IndexType) -> IndexDTO:
    return IndexDTO()


@app.post("/groups")
async def create_word_group(word_group: WordGroup) -> bool:
    return True


@app.put("/groups")
async def create_word_group(word_group: WordGroup) -> bool:
    return True


@app.get("/groups")
async def get_word_groups() -> List[WordGroup]:
    return []


@app.post("/phrases")
async def create_phrase(phrase: Phrase) -> bool:
    return True


@app.get("/phrases")
async def get_phrases() -> List[Phrase]:
    return []


@app.get("/stats")
async def get_stats() -> List[StatsDTO]:
    return []
