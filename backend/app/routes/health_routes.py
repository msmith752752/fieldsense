from fastapi import APIRouter

router = APIRouter(
    prefix="/api/v1",
    tags=["Health"]
)

@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "app": "FieldSense",
        "version": "0.1.0",
        "message": "FieldSense backend running"
    }