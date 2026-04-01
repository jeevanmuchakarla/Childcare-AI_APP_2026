from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
import models
from database import engine, Base

app = FastAPI()

# Initialize the routers
from routes import auth_routes, profile_routes, provider_routes, booking_routes, ai_routes, review_routes, message_routes, admin_routes, notification_routes, meal_routes, activity_routes, provider_stats_routes, upload_routes

# Create tables
Base.metadata.create_all(bind=engine)

from fastapi.responses import FileResponse

@app.get("/api")
def home():
    return {"message": "Childcare AI Backend Connected to MySQL"}

@app.get("/privacy-policy")
def get_privacy_policy():
    return FileResponse("static/privacy-policy.html")

# Create uploads directory if it doesn't exist
import os
os.makedirs("uploads/certifications", exist_ok=True)

# Mount static files
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")
app.mount("/static", StaticFiles(directory="static"), name="static")

# Setup CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Expand this in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/api/health")
def health_check():
    return {"status": "Healthy", "db": str(engine.url)}

# Include routers
app.include_router(auth_routes.router)
app.include_router(profile_routes.router)
app.include_router(provider_routes.router)
app.include_router(booking_routes.router)
app.include_router(ai_routes.router)
app.include_router(review_routes.router)
app.include_router(message_routes.router)
app.include_router(admin_routes.router)
app.include_router(notification_routes.router)
app.include_router(meal_routes.router)
app.include_router(activity_routes.router)
app.include_router(provider_stats_routes.router)
app.include_router(upload_routes.router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
