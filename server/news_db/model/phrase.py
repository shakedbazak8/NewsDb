from pydantic_xml import BaseXmlModel, attr


class Phrase(BaseXmlModel):
    phrase: str = attr()
    definition: str = attr()