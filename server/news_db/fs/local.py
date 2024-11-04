import tempfile

from news_db.fs.base import BaseFs


class LocalFs(BaseFs):

    def __init__(self):
        super().__init__()

    def store(self, data: str) -> str:
        with tempfile.NamedTemporaryFile('w') as io:
            io.write(data)
            return io.name

    def fetch(self, path: str) -> str:
        with open(path, 'r') as io:
            return io.read()
