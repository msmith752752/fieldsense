from fastapi import APIRouter

router = APIRouter()

@router.get("/health")
def health_check():
    return {
        "status": "healthy",
        "app": "FieldSense",
        "message": "FieldSense backend running"
    }