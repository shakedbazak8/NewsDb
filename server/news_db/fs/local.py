import os
import uuid

from news_db.fs.base import BaseFs


class LocalFs(BaseFs):

    def __init__(self, base_dir: str):
        super().__init__()
        self._base_dir = base_dir

    def store(self, data: str) -> str:
        with open(os.path.join(self._base_dir, f"{str(uuid.uuid4())}.txt"), 'w') as io:
            io.write(data)
            return io.name

    def fetch(self, path: str) -> str:
        with open(path, 'r') as io:
            return io.read()
