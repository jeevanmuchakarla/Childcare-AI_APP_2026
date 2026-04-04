import SwiftUI
import Combine

/// Manages the user's consent for sending data to the AI service.
/// Consent is persisted in UserDefaults so it survives app restarts.
public class AIConsentManager: ObservableObject {
    public static let shared = AIConsentManager()

    private let consentKey = "ai_consent_granted"

    @Published public var hasConsent: Bool

    private init() {
        self.hasConsent = UserDefaults.standard.bool(forKey: consentKey)
    }

    /// Persist consent grant.
    public func grantConsent() {
        hasConsent = true
        UserDefaults.standard.set(true, forKey: consentKey)
    }

    /// Clear consent (e.g. user revokes from Settings).
    public func revokeConsent() {
        hasConsent = false
        UserDefaults.standard.set(false, forKey: consentKey)
    }
}
