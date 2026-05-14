from fastapi import FastAPI
from routes.health_routes import router as health_router

app = FastAPI(
    title="FieldSense API"
)

app.include_router(health_router)