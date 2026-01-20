import Foundation

/// Configuration for connecting to Zoho Books API
public struct ZohoConfig: Sendable {
    /// OAuth client ID
    public let clientId: String

    /// OAuth client secret
    public let clientSecret: String

    /// Current OAuth access token
    public let accessToken: String

    /// OAuth refresh token for obtaining new access tokens
    public let refreshToken: String

    /// Zoho Books organization ID
    public let organizationId: String

    /// Zoho region (com, eu, in, au, jp)
    public let region: ZohoRegion

    /// Base URL for the Zoho Books API
    public var baseURL: String {
        "https://www.zohoapis.\(region.rawValue)/books/v3"
    }

    /// OAuth token endpoint URL
    public var oauthURL: String {
        "https://accounts.zoho.\(region.rawValue)/oauth/v2/token"
    }

    public init(
        clientId: String,
        clientSecret: String,
        accessToken: String,
        refreshToken: String,
        organizationId: String,
        region: ZohoRegion = .com
    ) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.organizationId = organizationId
        self.region = region
    }
}

/// Zoho data center regions
public enum ZohoRegion: String, Sendable, Codable {
    case com = "com"
    case eu = "eu"
    case `in` = "in"
    case au = "au"
    case jp = "jp"
}
