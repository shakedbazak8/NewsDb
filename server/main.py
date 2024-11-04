import uvicorn

if __name__ == '__main__':
    uvicorn.run(app="news_controller:app", reload=True)
