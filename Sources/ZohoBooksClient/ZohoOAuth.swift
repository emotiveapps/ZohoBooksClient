import Foundation

/// Response from OAuth token refresh
struct TokenRefreshResponse: Codable, Sendable {
    let accessToken: String
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

/// Manages OAuth token refresh for Zoho Books API
public actor ZohoOAuth {
    private var accessToken: String
    private var refreshToken: String
    private let clientId: String
    private let clientSecret: String
    private let oauthURL: String

    /// Callback invoked when tokens are refreshed, allowing persistence
    public var onTokenRefresh: (@Sendable (String, String) async -> Void)?

    /// Current access token
    public var currentAccessToken: String {
        accessToken
    }

    /// Current refresh token
    public var currentRefreshToken: String {
        refreshToken
    }

    public init(config: ZohoConfig) {
        self.accessToken = config.accessToken
        self.refreshToken = config.refreshToken
        self.clientId = config.clientId
        self.clientSecret = config.clientSecret
        self.oauthURL = config.oauthURL
    }

    /// Refresh the OAuth access token using the refresh token
    /// - Returns: The new access token
    @discardableResult
    public func refreshAccessToken() async throws -> String {
        var components = URLComponents(string: oauthURL)!
        components.queryItems = [
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "client_secret", value: clientSecret),
            URLQueryItem(name: "grant_type", value: "refresh_token")
        ]

        guard let url = components.url else {
            throw ZohoError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ZohoError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ZohoError.tokenRefreshFailed(errorMessage)
        }

        let tokenResponse = try JSONDecoder().decode(TokenRefreshResponse.self, from: data)
        accessToken = tokenResponse.accessToken

        if let newRefreshToken = tokenResponse.refreshToken {
            refreshToken = newRefreshToken
        }

        // Notify callback of token refresh
        if let callback = onTokenRefresh {
            await callback(accessToken, refreshToken)
        }

        return accessToken
    }

    /// Update tokens manually (e.g., after initial OAuth flow)
    public func updateTokens(accessToken: String, refreshToken: String) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}
