import Foundation

/// Protocol for OAuth authentication providers.
/// Abstracts away the concrete OAuth implementation to allow easy swapping of libraries.
public protocol OAuthProviding: Actor {
  /// The current access token, if available
  var currentAccessToken: String { get async }

  /// Refresh the access token
  /// - Returns: The new access token
  @discardableResult
  func refreshAccessToken() async throws -> String

  /// Check if the user is currently authenticated
  var isAuthenticated: Bool { get async }
}

/// Extended protocol for OAuth providers that support interactive authorization flow
public protocol InteractiveOAuthProviding: OAuthProviding {
  /// Perform the full OAuth authorization flow
  /// This typically presents a web view for user login
  #if canImport(AuthenticationServices)
    @MainActor
    func authorize() async throws
  #endif
}

/// Configuration for Zoho OAuth
public struct ZohoOAuthConfig: Sendable {
  public let clientId: String
  public let clientSecret: String
  public let redirectURI: URL
  public let scopes: [String]
  public let region: ZohoRegion

  /// Authorization URL for the region
  public var authorizationURL: URL {
    URL(string: "https://accounts.zoho.\(region.rawValue)/oauth/v2/auth")!
  }

  /// Token URL for the region
  public var tokenURL: URL {
    URL(string: "https://accounts.zoho.\(region.rawValue)/oauth/v2/token")!
  }

  /// Common Zoho Books scopes
  public static let defaultScopes = [
    "ZohoBooks.fullaccess.all"
  ]

  public init(
    clientId: String,
    clientSecret: String,
    redirectURI: URL,
    scopes: [String] = ZohoOAuthConfig.defaultScopes,
    region: ZohoRegion = .com
  ) {
    self.clientId = clientId
    self.clientSecret = clientSecret
    self.redirectURI = redirectURI
    self.scopes = scopes
    self.region = region
  }
}
