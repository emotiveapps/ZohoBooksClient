import XCTest
@testable import ZohoBooksClient

final class ZohoOAuthConfigTests: XCTestCase {
  // MARK: - ZohoRegion Tests

  func testZohoRegionRawValues() {
    XCTAssertEqual(ZohoRegion.com.rawValue, "com")
    XCTAssertEqual(ZohoRegion.europe.rawValue, "eu")
    XCTAssertEqual(ZohoRegion.india.rawValue, "in")
    XCTAssertEqual(ZohoRegion.australia.rawValue, "au")
    XCTAssertEqual(ZohoRegion.japan.rawValue, "jp")
  }

  // MARK: - ZohoOAuthConfig Tests

  func testZohoOAuthConfigInitialization() {
    let redirectURI = URL(string: "myapp://oauth/callback")!
    let config = ZohoOAuthConfig(
      clientId: "test-client-id",
      clientSecret: "test-client-secret",
      redirectURI: redirectURI,
      scopes: ["ZohoBooks.fullaccess.all"],
      region: .com
    )

    XCTAssertEqual(config.clientId, "test-client-id")
    XCTAssertEqual(config.clientSecret, "test-client-secret")
    XCTAssertEqual(config.redirectURI, redirectURI)
    XCTAssertEqual(config.scopes, ["ZohoBooks.fullaccess.all"])
    XCTAssertEqual(config.region, .com)
  }

  func testZohoOAuthConfigDefaultScopes() {
    XCTAssertEqual(ZohoOAuthConfig.defaultScopes, ["ZohoBooks.fullaccess.all"])
  }

  func testZohoOAuthConfigDefaultRegion() {
    let redirectURI = URL(string: "myapp://oauth/callback")!
    let config = ZohoOAuthConfig(
      clientId: "id",
      clientSecret: "secret",
      redirectURI: redirectURI
    )
    XCTAssertEqual(config.region, .com)
    XCTAssertEqual(config.scopes, ZohoOAuthConfig.defaultScopes)
  }

  func testZohoOAuthConfigAuthorizationURL() {
    let redirectURI = URL(string: "myapp://oauth/callback")!

    let comConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .com)
    XCTAssertEqual(comConfig.authorizationURL.absoluteString, "https://accounts.zoho.com/oauth/v2/auth")

    let euConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .europe)
    XCTAssertEqual(euConfig.authorizationURL.absoluteString, "https://accounts.zoho.eu/oauth/v2/auth")

    let inConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .india)
    XCTAssertEqual(inConfig.authorizationURL.absoluteString, "https://accounts.zoho.in/oauth/v2/auth")

    let auConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .australia)
    XCTAssertEqual(auConfig.authorizationURL.absoluteString, "https://accounts.zoho.au/oauth/v2/auth")

    let jpConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .japan)
    XCTAssertEqual(jpConfig.authorizationURL.absoluteString, "https://accounts.zoho.jp/oauth/v2/auth")
  }

  func testZohoOAuthConfigTokenURL() {
    let redirectURI = URL(string: "myapp://oauth/callback")!

    let comConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .com)
    XCTAssertEqual(comConfig.tokenURL.absoluteString, "https://accounts.zoho.com/oauth/v2/token")

    let euConfig = ZohoOAuthConfig(
      clientId: "id", clientSecret: "secret", redirectURI: redirectURI, region: .europe)
    XCTAssertEqual(euConfig.tokenURL.absoluteString, "https://accounts.zoho.eu/oauth/v2/token")
  }

  // MARK: - ZohoConfig URL Tests

  func testZohoConfigBaseURLAllRegions() {
    let comConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .com)
    XCTAssertEqual(comConfig.baseURL, "https://www.zohoapis.com/books/v3")

    let euConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .europe)
    XCTAssertEqual(euConfig.baseURL, "https://www.zohoapis.eu/books/v3")

    let inConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .india)
    XCTAssertEqual(inConfig.baseURL, "https://www.zohoapis.in/books/v3")

    let auConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .australia)
    XCTAssertEqual(auConfig.baseURL, "https://www.zohoapis.au/books/v3")

    let jpConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .japan)
    XCTAssertEqual(jpConfig.baseURL, "https://www.zohoapis.jp/books/v3")
  }

  func testZohoConfigOAuthURLAllRegions() {
    let comConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .com)
    XCTAssertEqual(comConfig.oauthURL, "https://accounts.zoho.com/oauth/v2/token")

    let euConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .europe)
    XCTAssertEqual(euConfig.oauthURL, "https://accounts.zoho.eu/oauth/v2/token")

    let auConfig = ZohoConfig(
      clientId: "id", clientSecret: "secret", accessToken: "token",
      refreshToken: "refresh", organizationId: "org", region: .australia)
    XCTAssertEqual(auConfig.oauthURL, "https://accounts.zoho.au/oauth/v2/token")
  }
}
