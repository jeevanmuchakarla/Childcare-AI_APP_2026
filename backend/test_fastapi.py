from fastapi import FastAPI
from datetime import datetime
import uvicorn
app = FastAPI()
@app.get("/")
def test():
    return {"time": datetime.now()}
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
