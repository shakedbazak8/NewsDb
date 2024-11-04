import uvicorn

from news_db import config

if __name__ == '__main__':
    uvicorn.run(app="news_db.news_controller:app", reload=True, host=config.HOST, port=config.PORT)
