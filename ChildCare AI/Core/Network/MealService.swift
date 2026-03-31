import Foundation

public struct MealModel: Codable, Identifiable {
    public let id: Int
    public let child_id: Int
    public let provider_id: Int
    public let meal_type: String
    public let food_item: String
    public let amount_eaten: String
    public let created_at: String
}

public class MealService: BaseService {
    public static let shared = MealService()
    
    public func createMealRecord(
        childId: Int,
        providerId: Int,
        mealType: String,
        foodItem: String,
        amountEaten: String
    ) async throws -> MealModel {
        let payload: [String: Any] = [
            "child_id": childId,
            "provider_id": providerId,
            "meal_type": mealType,
            "food_item": foodItem,
            "amount_eaten": amountEaten
        ]
        
        
        let response: MealModel = try await performRequest(
            endpoint: "/meals/",
            method: "POST",
            body: payload
        )
        return response
    }
    
    public func fetchChildMeals(childId: Int) async throws -> [MealModel] {
        return try await performRequest(endpoint: "/meals/child/\(childId)")
    }
    
    public func fetchProviderMeals(providerId: Int) async throws -> [MealModel] {
        return try await performRequest(endpoint: "/meals/provider/\(providerId)")
    }
}
