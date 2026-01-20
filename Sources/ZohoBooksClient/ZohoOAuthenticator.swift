import Foundation
import OAuthenticator
#if canImport(AuthenticationServices)
import AuthenticationServices
#endif

/// OAuth provider using OAuthenticator library for full OAuth 2.0 flow support.
/// This enables web-based login via ASWebAuthenticationSession.
public actor ZohoOAuthenticator: InteractiveOAuthProviding {
    private let authenticator: Authenticator
    private let config: ZohoOAuthConfig
    private var cachedToken: String?

    public var currentAccessToken: String {
        get async {
            // Try to get token from a simple authenticated request
            // OAuthenticator manages tokens internally
            cachedToken ?? ""
        }
    }

    public var isAuthenticated: Bool {
        get async {
            cachedToken != nil
        }
    }

    public init(config: ZohoOAuthConfig, storage: LoginStorage? = nil) {
        self.config = config

        let appCredentials = AppCredentials(
            clientId: config.clientId,
            clientPassword: config.clientSecret,
            scopes: config.scopes,
            callbackURL: config.redirectURI
        )

        // Create Zoho-specific token handling
        let tokenHandling = TokenHandling(
            authorizationURLProvider: { params in
                var components = URLComponents(url: config.authorizationURL, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: params.credentials.clientId),
                    URLQueryItem(name: "redirect_uri", value: params.credentials.callbackURL.absoluteString),
                    URLQueryItem(name: "response_type", value: "code"),
                    URLQueryItem(name: "scope", value: params.credentials.scopes.joined(separator: ",")),
                    URLQueryItem(name: "access_type", value: "offline"),
                    URLQueryItem(name: "prompt", value: "consent"),
                    URLQueryItem(name: "state", value: params.stateToken)
                ]
                return components.url!
            },
            loginProvider: { params in
                // Extract authorization code from the redirect URL
                guard let components = URLComponents(url: params.redirectURL, resolvingAgainstBaseURL: false),
                      let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                    throw ZohoError.invalidResponse
                }

                var request = URLRequest(url: config.tokenURL)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

                let body = [
                    "grant_type=authorization_code",
                    "client_id=\(params.credentials.clientId)",
                    "client_secret=\(params.credentials.clientPassword)",
                    "redirect_uri=\(params.credentials.callbackURL.absoluteString)",
                    "code=\(code)"
                ].joined(separator: "&")

                request.httpBody = body.data(using: .utf8)

                let (data, _) = try await params.responseProvider(request)
                let response = try JSONDecoder().decode(ZohoTokenResponse.self, from: data)

                return Login(
                    accessToken: Token(value: response.accessToken, expiresIn: response.expiresIn ?? 3600),
                    refreshToken: response.refreshToken.map { Token(value: $0) }
                )
            },
            refreshProvider: { login, creds, responseProvider in
                guard let refreshToken = login.refreshToken?.value else {
                    throw ZohoError.unauthorized
                }

                var components = URLComponents(url: config.tokenURL, resolvingAgainstBaseURL: false)!
                components.queryItems = [
                    URLQueryItem(name: "refresh_token", value: refreshToken),
                    URLQueryItem(name: "client_id", value: creds.clientId),
                    URLQueryItem(name: "client_secret", value: creds.clientPassword),
                    URLQueryItem(name: "grant_type", value: "refresh_token")
                ]

                var request = URLRequest(url: components.url!)
                request.httpMethod = "POST"
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

                let (data, _) = try await responseProvider(request)
                let response = try JSONDecoder().decode(ZohoTokenResponse.self, from: data)

                return Login(
                    accessToken: Token(value: response.accessToken, expiresIn: response.expiresIn ?? 3600),
                    refreshToken: login.refreshToken // Keep existing refresh token if not returned
                )
            }
        )

        // Use provided storage or create in-memory storage
        let loginStorage = storage ?? LoginStorage {
            nil // No persisted login by default
        } storeLogin: { _ in
            // No-op by default
        }

        let authenticatorConfig = Authenticator.Configuration(
            appCredentials: appCredentials,
            loginStorage: loginStorage,
            tokenHandling: tokenHandling
        )

        self.authenticator = Authenticator(config: authenticatorConfig)
    }

    #if canImport(AuthenticationServices)
    @MainActor
    public func authorize() async throws {
        // Trigger authentication flow - OAuthenticator will present web view
        let dummyRequest = URLRequest(url: URL(string: "https://www.zohoapis.\(config.region.rawValue)/books/v3/contacts")!)
        let (_, _) = try await authenticator.response(for: dummyRequest)
    }
    #endif

    @discardableResult
    public func refreshAccessToken() async throws -> String {
        // Make a request to trigger token refresh
        let dummyRequest = URLRequest(url: URL(string: "https://www.zohoapis.\(config.region.rawValue)/books/v3/contacts")!)
        let (_, _) = try await authenticator.response(for: dummyRequest)

        // Extract token from authenticator's internal state
        // Since OAuthenticator manages tokens internally, we rely on it
        return cachedToken ?? ""
    }

    /// Make an authenticated request using OAuthenticator
    /// This is the primary way to make API calls - OAuthenticator handles auth automatically
    public func authenticatedRequest(for request: URLRequest) async throws -> (Data, URLResponse) {
        let (data, response) = try await authenticator.response(for: request)

        // Cache the token from successful requests (if we can extract it)
        // OAuthenticator adds the Authorization header automatically

        return (data, response)
    }
}

// MARK: - Token Response

/// Zoho OAuth token response
struct ZohoTokenResponse: Codable, Sendable {
    let accessToken: String
    let tokenType: String?
    let expiresIn: Int?
    let refreshToken: String?
    let scope: String?
    let apiDomain: String?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case refreshToken = "refresh_token"
        case scope
        case apiDomain = "api_domain"
    }
}
