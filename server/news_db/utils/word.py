import re
from typing import List

from news_db.dto.index import IndexDTO
from news_db.model.index import Index
from news_db.model.index_type import IndexType


def extract_words_with_paragraph_and_line(text) -> List[IndexDTO]:
    words_info = []

    # Split text into paragraphs (two newlines or more)
    paragraphs = text.split("\n\n")

    for para_num, paragraph in enumerate(paragraphs, start=1):
        # Split paragraph into lines
        lines = paragraph.split("\n")

        for line_num, line in enumerate(lines, start=1):
            # Split the line into words using regex to handle punctuation and spaces
            words = re.findall(r'\w+', line)  # This finds sequences of alphanumeric characters

            for word in words:
                words_info.append(
                    IndexDTO(index=word, line=line_num, paragraph=para_num, type=IndexType.WORD)
                )

    return words_info
