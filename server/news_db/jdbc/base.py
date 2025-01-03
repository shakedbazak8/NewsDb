from abc import ABC, abstractmethod
from typing import List, Optional, Dict, Any

from news_db.dto.article import ArticleDTO
from news_db.dto.index import IndexDTO
from news_db.dto.word_group import WordGroupDTO
from news_db.model.article import Article
from news_db.model.index import Index
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup


class BaseJdbc(ABC):

    @abstractmethod
    def fetch(self, article: Article) -> Article:
        pass

    @abstractmethod
    def insert(self, article: Article) -> str:
        pass

    @abstractmethod
    def find_all(self, article: ArticleDTO) -> List[Article]:
        pass

    @abstractmethod
    def find_all_by_name(self, title: str) -> List[Article]:
        pass

    @abstractmethod
    def find_all_by_words(self, words: List[str]) -> List[Article]:
        pass

    @abstractmethod
    def insert_group(self, group: WordGroup) -> bool:
        pass

    @abstractmethod
    def get_groups(self, group: WordGroupDTO) -> List[WordGroup]:
        pass

    @abstractmethod
    def insert_phrase(self, phrase: Phrase) -> bool:
        pass

    @abstractmethod
    def get_phrases(self) -> List[Phrase]:
        pass

    @abstractmethod
    def store_indices(self, indices: List[Index]) -> bool:
        pass

    @abstractmethod
    def get_words(self, article: Optional[ArticleDTO] = None) -> List[str]:
        pass

    @abstractmethod
    def get_by_index(self, index: IndexDTO, articles: List[str]) -> List[str]:
        pass

    @abstractmethod
    def basic_stats(self) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    def words_histogram(self) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    def group_histogram(self) -> List[Dict[str, Any]]:
        pass

    @abstractmethod
    def get_all_articles(self) -> List[Article]:
        pass

    @abstractmethod
    def get_all_indices(self) -> List[Index]:
        pass

    @abstractmethod
    def get_all_groups(self) -> List[WordGroup]:
        pass

    @abstractmethod
    def get_all_phrases(self) -> List[Phrase]:
        pass

    @abstractmethod
    def insert_all_articles(self, articles: List[Article]) -> bool:
        pass

    @abstractmethod
    def insert_all_indices(self, indices: List[Index]) -> bool:
        pass

    @abstractmethod
    def insert_all_groups(self, groups: List[WordGroup]) -> bool:
        pass

    @abstractmethod
    def insert_all_phrases(self, phrases: List[Phrase]) -> bool:
        pass

    @abstractmethod
    def find_article_by_id(self, id: str) -> List[Article]:
        pass



