import re
from typing import List


def extract_words(text: str) -> List[str]:
    return re.findall(r"\w+", text)
