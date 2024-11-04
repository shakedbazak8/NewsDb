import uvicorn

import config

if __name__ == '__main__':
    uvicorn.run(app="news_controller:app", reload=True, host=config.HOST, port=config.PORT)
