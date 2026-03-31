from fastapi import APIRouter, Query, Depends
from typing import Optional, List
from pydantic import BaseModel
import json
import os
import random

router = APIRouter(prefix="/api/ai", tags=["ai"])

class AIRecommendation(BaseModel):
    id: int
    name: str
    provider_type: str
    rating: float
    distance_km: float
    monthly_price: int
    match_score: int
    experience: Optional[str] = None
    address: Optional[str] = None
    phone: Optional[str] = None
    timing: Optional[str] = None
    age_range: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    
@router.get("/recommendations", response_model=List[AIRecommendation])
def get_ai_recommendations(
    provider_type: str = Query(..., description="Type of provider (Preschool, Daycare)"),
    budget: str = Query(..., description="Budget preference (Budget Friendly, Standard, Premium)"),
    location: Optional[str] = Query(None, description="Preferred area location"),
    age: Optional[str] = Query(None, description="Age requirement"),
    timing: Optional[str] = Query(None, description="Timing requirement"),
    lat: Optional[float] = Query(None, description="Parent latitude"),
    lon: Optional[float] = Query(None, description="Parent longitude")
):
    results = []
    
    file_path = os.path.join(os.path.dirname(__file__), '../../dataset/world_childcares.json')
    try:
        with open(file_path, 'r') as f:
            dataset = json.load(f)
    except Exception as e:
        print(f"Error loading AI dataset: {e}")
        return []
        
    role_filter = provider_type.rstrip('s') # E.g., 'Preschools' -> 'Preschool'
    
    # Simple deterministic matching based solely on the dataset
    provider_id_counter = 5000 # Give them high IDs to avoid collision with real users if ever needed
    
    for p in dataset:
        provider_id_counter += 1
        
        # Type filter
        p_type = p.get('type', '')
        if role_filter.lower() not in (p_type or '').lower():
            continue
            
        # Location filter
        if location and str(location).lower() not in ['null', 'none', 'anywhere in chennai', 'anywhere']:
            address = p.get('address', '')
            loc_lower = str(location).lower()
            addr_lower = str(address).lower()
            if loc_lower not in addr_lower:
                continue
            
        # Budget filter mapping from JSON budget to numeric price
        p_budget = p.get('budget', 'Standard')
        if p_budget == 'Budget Friendly' or p_budget == 'Budget':
            price = random.randint(550, 850)
            price_match = 1.0 if budget in ["Budget Friendly", "Budget"] else 0.6
        elif p_budget == 'Premium':
            price = random.randint(1600, 3000)
            price_match = 1.0 if budget == "Premium" else 0.5
        else: # Standard
            price = random.randint(900, 1500)
            price_match = 1.0 if budget == "Standard" else 0.6
            
        # Scoring
        price_score = price_match * 100
        rating_score = (p.get('rating', 4.0) / 5.0) * 100
        
        match_score = int((price_score * 0.45) + (rating_score * 0.55))
        
        recommendation_data = {
            "id": provider_id_counter,
            "name": p.get('name', 'Unknown Center'),
            "provider_type": p_type,
            "rating": p.get('rating', 4.0),
            "distance_km": float(p.get('distance', 0.0)),
            "monthly_price": price,
            "match_score": min(99, match_score),
            "experience": "5+ Years",
            "address": p.get('address', ''),
            "phone": p.get('phone', ''),
            "timing": p.get('timing', ''),
            "age_range": p.get('age', ''),
            "latitude": p.get('latitude'),
            "longitude": p.get('longitude')
        }
        results.append(AIRecommendation(**recommendation_data))
            
    # Sort by match score
    results.sort(key=lambda x: x.match_score, reverse=True)
    
    # Return first 10 results
    return results[:10]
