from fastapi import FastAPI
from routes.health_routes import router as health_router
from routes.field_routes import router as field_router

app = FastAPI(
    title="FieldSense API",
    description="Field intelligence API for rainfall, crop, and operational decision support.",
    version="0.1.0"
)

app.include_router(health_router)
app.include_router(field_router)