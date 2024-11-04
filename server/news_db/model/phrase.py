from pydantic import BaseModel


class Phrase(BaseModel):
    phrase: str
    definition: str