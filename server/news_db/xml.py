from news_db.model.db import Db


class Xml:

    def export_db(self, db: Db) -> bytes:
        try:
            return db.to_xml()
        except:
            raise ValueError("Unsupported Format")

    def import_db(self, data: bytes) -> Db:
        try:
            return Db.from_xml(data)
        except:
            raise ValueError("Invalid XML data")
