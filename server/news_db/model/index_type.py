from enum import Enum


class IndexType(str, Enum):
    WORD = 'word'
    GROUP = 'group'
    PHRASE = 'phrase'