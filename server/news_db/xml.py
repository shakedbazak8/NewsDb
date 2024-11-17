from news_db.model.db import Db


class Xml:

    def export_db(self, db: Db, path: str) -> bool:
        try:
            with open(path, 'wb') as io:
                io.write(db.to_xml())
                return True
        except:
            return False

    def import_db(self, path: str) -> Db:
        try:
            with open(path, 'rb') as io:
                db = Db.from_xml(io.read())
                return db
        except:
            raise ValueError("Invalid XML data")
