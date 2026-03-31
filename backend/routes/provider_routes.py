from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import Optional
from database import get_db
from math import sin, cos, sqrt, atan2, radians
import models, schemas

router = APIRouter(prefix="/api/providers", tags=["providers"])

@router.get("/", response_model=dict)
def get_providers(
    role: Optional[str] = None, 
    lat: Optional[float] = None, 
    lon: Optional[float] = None, 
    max_dist: Optional[float] = None,
    db: Session = Depends(get_db)
):
    # Optimized: Use a single query with a join
    query = db.query(models.Center, models.User.role) \
        .join(models.User, models.Center.user_id == models.User.id) \
        .filter(models.Center.status == "Approved")
        
    if role:
        query = query.filter(models.User.role == role)
        
    results = query.all()
    
    providers = []
    
    # Helper for distance
    def calculate_distance(lat1: Optional[float], lon1: Optional[float], lat2: Optional[float], lon2: Optional[float]) -> float:
        # approximate radius of earth in km
        R = 6373.0
        
        # At this point, we perform a final check and use local variables to ensure float types
        # Using explicit float() conversion only after checking for None to satisfy Pyright
        if lat1 is not None and lon1 is not None and lat2 is not None and lon2 is not None:
            phi1, lam1, phi2, lam2 = map(radians, [lat1, lon1, lat2, lon2])
            dlon = lam2 - lam1
            dlat = phi2 - phi1
            a = sin(dlat / 2)**2 + cos(phi1) * cos(phi2) * sin(dlon / 2)**2
            c = 2 * atan2(sqrt(a), sqrt(1 - a))
            res = float(R * c)
            return float(f"{res:.1f}")
            
        return 999.9

    for center, user_role in results:
        dist = calculate_distance(lat, lon, center.latitude, center.longitude)
        if isinstance(max_dist, (int, float)):
            if dist > float(max_dist): 
                continue
        
        center_dict = {k: v for k, v in center.__dict__.items() if not k.startswith('_')}
        center_dict['type'] = user_role.value
        center_dict['distance_km'] = dist
        providers.append(center_dict)
            
    # Sort by distance if coordinates provided
    if lat is not None and lon is not None:
        providers.sort(key=lambda x: x.get('distance_km', 999))
            
    return {"providers": providers}

@router.get("/counts", response_model=dict)
def get_provider_counts(db: Session = Depends(get_db)):
    """Lightweight endpoint for dashboard counts."""
    preschool_count = db.query(models.Center) \
        .join(models.User, models.Center.user_id == models.User.id) \
        .filter(models.Center.status == "Approved", models.User.role == models.UserRole.PRESCHOOL).count()
        
    daycare_count = db.query(models.Center) \
        .join(models.User, models.Center.user_id == models.User.id) \
        .filter(models.Center.status == "Approved", models.User.role == models.UserRole.DAYCARE).count()
        
    return {"Preschool": preschool_count, "Daycare": daycare_count}

@router.get("/{provider_id}", response_model=dict)
def get_provider(provider_id: int, db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.id == provider_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Provider not found")
        
    if user.role in [models.UserRole.PRESCHOOL, models.UserRole.DAYCARE]:
        center = db.query(models.Center).filter(models.Center.user_id == provider_id).first()
        if center:
            return {k: v for k, v in center.__dict__.items() if not k.startswith('_')}

            
    raise HTTPException(status_code=404, detail="Provider not found")
