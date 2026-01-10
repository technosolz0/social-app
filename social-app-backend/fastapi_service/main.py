from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
import uvicorn
import sys
import os

# Add the current directory to Python path for imports
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config import settings
from routers import feed, recommendations, analytics

app = FastAPI(title="Social App High-Performance API", version="1.0.0")

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Encryption
from middleware.encryption import EncryptionMiddleware
app.add_middleware(EncryptionMiddleware)

# Include routers
app.include_router(feed.router, prefix="/feed", tags=["feed"])
app.include_router(recommendations.router, prefix="/recommendations", tags=["recommendations"])
app.include_router(analytics.router, prefix="/analytics", tags=["analytics"])

@app.get("/")
def root():
    return {"message": "Social App FastAPI Service", "status": "running"}

@app.get("/health")
def health_check():
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001, reload=True)
