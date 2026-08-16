import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct ZohoOAuthConfigTests {
  // MARK: - ZohoRegion Tests

  @Test func zohoRegionRawValues() {
    #expect(ZohoRegion.com.rawValue == "com")
    #expect(ZohoRegion.europe.rawValue == "eu")
    #expect(ZohoRegion.india.rawValue == "in")
    #expect(ZohoRegion.australia.rawValue == "au")
    #expect(ZohoRegion.japan.rawValue == "jp")
  }

  // MARK: - ZohoOAuthConfig Tests

  @Test func zohoOAuthConfigInitialization() {
    let redirectURI = URL(string: "myapp://oauth/callback")!
    let config = ZohoOAuthConfig(
      clientId: "test-client-id",
      clientSecret: "test-client-secret",
      redirectURI: redirectURI,
      scopes: ["ZohoBooks.fullaccess.all"],
      region: .com
    )

    #expect(config.clientId == "test-client-id")
    #expect(config.clientSecret == "test-client-secret")
    #expect(config.redirectURI == redirectURI)
    #expect(config.scopes == ["ZohoBooks.fullaccess.all"])
    #expect(config.region == .com)
  }

  @Test func zohoOAuthConfigDefaultScopes() {
    #expect(ZohoOAuthConfig.defaultScopes == ["ZohoBooks.fullaccess.all"])
  }

  @Test func zohoOAuthConfigDefaultRegion() {
    let redirectURI = URL(string: "myapp://oauth/callback")!
    let config = ZohoOAuthConfig(
      clientId: "id",
      clientSecret: "secret",
      redirectURI: redirectURI
    )
    #expect(config.region == .com)
    #expect(config.scopes == ZohoOAuthConfig.defaultScopes)
  }

  @Test func zohoOAuthConfigAuthorizationURL() {
    let redirectURI = URL(string: "myapp://oauth/callback")!

    let comConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .com
    )
    #expect(comConfig.authorizationURL.absoluteString == "https://accounts.zoho.com/oauth/v2/auth")

    let euConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .europe
    )
    #expect(euConfig.authorizationURL.absoluteString == "https://accounts.zoho.eu/oauth/v2/auth")

    let inConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .india
    )
    #expect(inConfig.authorizationURL.absoluteString == "https://accounts.zoho.in/oauth/v2/auth")

    let auConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .australia
    )
    #expect(auConfig.authorizationURL.absoluteString == "https://accounts.zoho.au/oauth/v2/auth")

    let jpConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .japan
    )
    #expect(jpConfig.authorizationURL.absoluteString == "https://accounts.zoho.jp/oauth/v2/auth")
  }

  @Test func zohoOAuthConfigTokenURL() {
    let redirectURI = URL(string: "myapp://oauth/callback")!

    let comConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .com
    )
    #expect(comConfig.tokenURL.absoluteString == "https://accounts.zoho.com/oauth/v2/token")

    let euConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .europe
    )
    #expect(euConfig.tokenURL.absoluteString == "https://accounts.zoho.eu/oauth/v2/token")
  }

  // MARK: - ZohoConfig URL Tests

  @Test func zohoConfigBaseURLAllRegions() {
    let comConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .com
    )
    #expect(comConfig.baseURL == "https://www.zohoapis.com/books/v3")

    let euConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .europe
    )
    #expect(euConfig.baseURL == "https://www.zohoapis.eu/books/v3")

    let inConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .india
    )
    #expect(inConfig.baseURL == "https://www.zohoapis.in/books/v3")

    let auConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .australia
    )
    #expect(auConfig.baseURL == "https://www.zohoapis.au/books/v3")

    let jpConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .japan
    )
    #expect(jpConfig.baseURL == "https://www.zohoapis.jp/books/v3")
  }

  @Test func zohoConfigOAuthURLAllRegions() {
    let comConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .com
    )
    #expect(comConfig.oauthURL == "https://accounts.zoho.com/oauth/v2/token")

    let euConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .europe
    )
    #expect(euConfig.oauthURL == "https://accounts.zoho.eu/oauth/v2/token")

    let auConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .australia
    )
    #expect(auConfig.oauthURL == "https://accounts.zoho.au/oauth/v2/token")
  }
}
