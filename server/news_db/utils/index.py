import re
from typing import List

from news_db.dto.index import IndexDTO
from news_db.model.index_type import IndexType
from news_db.model.phrase import Phrase
from news_db.model.word_group import WordGroup


def get_paragraphs(text: str) -> List[str]:
    return text.split("\n\n")


def get_lines(text: str) -> List[str]:
    return text.split("\n")


def get_word_index(text: str) -> List[IndexDTO]:
    words_info = []
    paragraphs = get_paragraphs(text)

    for para_num, paragraph in enumerate(paragraphs, start=1):
        lines = get_lines(paragraph)

        for line_num, line in enumerate(lines, start=1):
            words = re.findall(r'\w+', line)
            for word in words:
                words_info.append(
                    IndexDTO(index=word, line=line_num, paragraph=para_num, type=IndexType.WORD)
                )
    return words_info


def get_group_indexes(text: str, groups: List[WordGroup]) -> List[IndexDTO]:
    groups_info = []
    paragraphs = text.split("\n\n")
    for para_num, paragraph in enumerate(paragraphs, start=1):
        lines = paragraph.split("\n")

        for line_num, line in enumerate(lines, start=1):
            for group in groups:
                for word in group.words:
                    if word in line:
                        groups_info.append(
                            IndexDTO(index=group.name, line=line_num, paragraph=paragraph, type=IndexType.GROUP)
                        )
    return groups_info


def get_phrase_indexes(text: str, phrases: List[Phrase]) -> List[IndexDTO]:
    phrases_info = []
    paragraphs = text.split("\n\n")
    for para_num, paragraph in enumerate(paragraphs, start=1):
        lines = paragraph.split("\n")

        for line_num, line in enumerate(lines, start=1):
            for phrase in phrases:
                if phrase.phrase in line:
                    phrases_info.append(
                        IndexDTO(index=phrase.phrase, line=line_num, paragraph=paragraph, type=IndexType.PHRASE)
                    )
    return phrases_info
