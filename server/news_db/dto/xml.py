from pydantic import BaseModel


class XmlDTO(BaseModel):
    filePath: str