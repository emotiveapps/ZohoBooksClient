import XCTest
@testable import ZohoBooksClient

final class ZohoErrorTests: XCTestCase {
  // MARK: - ZohoError Tests

  func testZohoErrorInvalidURL() {
    let error = ZohoError.invalidURL
    XCTAssertEqual(error.errorDescription, "Invalid Zoho Books API URL")
  }

  func testZohoErrorInvalidResponse() {
    let error = ZohoError.invalidResponse
    XCTAssertEqual(error.errorDescription, "Invalid API response")
  }

  func testZohoErrorUnauthorized() {
    let error = ZohoError.unauthorized
    XCTAssertEqual(error.errorDescription, "Unauthorized - access token may be expired")
  }

  func testZohoErrorRateLimited() {
    let error = ZohoError.rateLimited
    XCTAssertEqual(error.errorDescription, "Rate limit exceeded - too many requests")
  }

  func testZohoErrorHttpError() {
    let error = ZohoError.httpError(statusCode: 404, message: "Not Found")
    XCTAssertEqual(error.errorDescription, "HTTP error (404): Not Found")
  }

  func testZohoErrorApiError() {
    let error = ZohoError.apiError(code: 1001, message: "Invalid parameter")
    XCTAssertEqual(error.errorDescription, "Zoho API error (1001): Invalid parameter")
  }

  func testZohoErrorDecodingError() {
    let underlyingError = NSError(
      domain: "TestDomain", code: 1,
      userInfo: [NSLocalizedDescriptionKey: "Decoding failed"])
    let error = ZohoError.decodingError(underlyingError)
    XCTAssertTrue(error.errorDescription?.contains("Failed to decode response") ?? false)
  }

  func testZohoErrorNetworkError() {
    let underlyingError = NSError(
      domain: "NSURLErrorDomain", code: -1009,
      userInfo: [NSLocalizedDescriptionKey: "No internet connection"])
    let error = ZohoError.networkError(underlyingError)
    XCTAssertTrue(error.errorDescription?.contains("Network error") ?? false)
  }

  func testZohoErrorTokenRefreshFailed() {
    let error = ZohoError.tokenRefreshFailed("Invalid refresh token")
    XCTAssertEqual(error.errorDescription, "Token refresh failed: Invalid refresh token")
  }

  // MARK: - HttpServiceError Tests

  func testHttpServiceErrorInvalidUrl() {
    let error = HttpServiceError.invalidUrl
    XCTAssertEqual(error.errorDescription, "Invalid URL")
  }

  func testHttpServiceErrorInvalidResponse() {
    let error = HttpServiceError.invalidResponse
    XCTAssertEqual(error.errorDescription, "Invalid response")
  }

  func testHttpServiceErrorUnauthorized() {
    let error = HttpServiceError.unauthorized
    XCTAssertEqual(error.errorDescription, "Unauthorized")
  }

  func testHttpServiceErrorRateLimited() {
    let error = HttpServiceError.rateLimited
    XCTAssertEqual(error.errorDescription, "Rate limit exceeded")
  }

  func testHttpServiceErrorHttpError() {
    let error = HttpServiceError.httpError(statusCode: 500, message: "Internal Server Error")
    XCTAssertEqual(error.errorDescription, "HTTP error (500): Internal Server Error")
  }

  // MARK: - HttpServiceError to ZohoError Conversion

  func testHttpServiceErrorToZohoErrorInvalidUrl() {
    let httpError = HttpServiceError.invalidUrl
    let zohoError = httpError.toZohoError()
    if case .invalidURL = zohoError {
      // Success
    } else {
      XCTFail("Expected .invalidURL")
    }
  }

  func testHttpServiceErrorToZohoErrorInvalidResponse() {
    let httpError = HttpServiceError.invalidResponse
    let zohoError = httpError.toZohoError()
    if case .invalidResponse = zohoError {
      // Success
    } else {
      XCTFail("Expected .invalidResponse")
    }
  }

  func testHttpServiceErrorToZohoErrorUnauthorized() {
    let httpError = HttpServiceError.unauthorized
    let zohoError = httpError.toZohoError()
    if case .unauthorized = zohoError {
      // Success
    } else {
      XCTFail("Expected .unauthorized")
    }
  }

  func testHttpServiceErrorToZohoErrorRateLimited() {
    let httpError = HttpServiceError.rateLimited
    let zohoError = httpError.toZohoError()
    if case .rateLimited = zohoError {
      // Success
    } else {
      XCTFail("Expected .rateLimited")
    }
  }

  func testHttpServiceErrorToZohoErrorHttpError() {
    let httpError = HttpServiceError.httpError(statusCode: 403, message: "Forbidden")
    let zohoError = httpError.toZohoError()
    if case let .httpError(statusCode, message) = zohoError {
      XCTAssertEqual(statusCode, 403)
      XCTAssertEqual(message, "Forbidden")
    } else {
      XCTFail("Expected .httpError")
    }
  }
}
