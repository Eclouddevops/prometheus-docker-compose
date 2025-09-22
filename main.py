from fastapi import FastAPI
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
from fastapi.responses import Response

app = FastAPI()
ITEMS = {}
request_counter = Counter('my_requests_total', 'Total API requests')

@app.get("/")
def root():
    request_counter.inc()
    return {"message": "Hello, FastAPI!"}

@app.post("/items")
def create_item(item: dict):
    request_counter.inc()
    item_id = len(ITEMS) + 1
    ITEMS[item_id] = item
    return {"id": item_id, "item": item}

@app.get("/items/{item_id}")
def get_item(item_id: int):
    request_counter.inc()
    return ITEMS.get(item_id, {"error": "Item not found"})

@app.put("/items/{item_id}")
def update_item(item_id: int, item: dict):
    request_counter.inc()
    if item_id in ITEMS:
        ITEMS[item_id] = item
        return {"id": item_id, "item": item}
    return {"error":
