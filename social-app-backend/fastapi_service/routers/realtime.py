from fastapi import APIRouter

router = APIRouter()

@router.get("/realtime")
async def get_realtime():
    return {"realtime": "data"}
