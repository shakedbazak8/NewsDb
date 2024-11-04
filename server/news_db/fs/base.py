from abc import ABC, abstractmethod


class BaseFs(ABC):

    def __init__(self):
        pass

    @abstractmethod
    def fetch(self, path: str) -> str:
        pass

    @abstractmethod
    def store(self, data: str) -> str:
        pass