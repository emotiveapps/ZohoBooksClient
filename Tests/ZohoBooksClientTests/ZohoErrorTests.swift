import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct ZohoErrorTests {
  // MARK: - ZohoError Tests

  @Test func zohoErrorInvalidURL() {
    let error = ZohoError.invalidURL
    #expect(error.errorDescription == "Invalid Zoho Books API URL")
  }

  @Test func zohoErrorInvalidResponse() {
    let error = ZohoError.invalidResponse
    #expect(error.errorDescription == "Invalid API response")
  }

  @Test func zohoErrorUnauthorized() {
    let error = ZohoError.unauthorized
    #expect(error.errorDescription == "Unauthorized - access token may be expired")
  }

  @Test func zohoErrorRateLimited() {
    let error = ZohoError.rateLimited
    #expect(error.errorDescription == "Rate limit exceeded - too many requests")
  }

  @Test func zohoErrorHttpError() {
    let error = ZohoError.httpError(statusCode: 404, message: "Not Found")
    #expect(error.errorDescription == "HTTP error (404): Not Found")
  }

  @Test func zohoErrorApiError() {
    let error = ZohoError.apiError(code: 1001, message: "Invalid parameter")
    #expect(error.errorDescription == "Zoho API error (1001): Invalid parameter")
  }

  @Test func zohoErrorDecodingError() {
    let underlyingError = NSError(
      domain: "TestDomain", code: 1,
      userInfo: [NSLocalizedDescriptionKey: "Decoding failed"]
    )
    let error = ZohoError.decodingError(underlyingError)
    #expect(error.errorDescription?.contains("Failed to decode response") ?? false)
  }

  @Test func zohoErrorNetworkError() {
    let underlyingError = NSError(
      domain: "NSURLErrorDomain", code: -1009,
      userInfo: [NSLocalizedDescriptionKey: "No internet connection"]
    )
    let error = ZohoError.networkError(underlyingError)
    #expect(error.errorDescription?.contains("Network error") ?? false)
  }

  @Test func zohoErrorTokenRefreshFailed() {
    let error = ZohoError.tokenRefreshFailed("Invalid refresh token")
    #expect(error.errorDescription == "Token refresh failed: Invalid refresh token")
  }

  // MARK: - HttpServiceError Tests

  @Test func httpServiceErrorInvalidUrl() {
    let error = HttpServiceError.invalidUrl
    #expect(error.errorDescription == "Invalid URL")
  }

  @Test func httpServiceErrorInvalidResponse() {
    let error = HttpServiceError.invalidResponse
    #expect(error.errorDescription == "Invalid response")
  }

  @Test func httpServiceErrorUnauthorized() {
    let error = HttpServiceError.unauthorized
    #expect(error.errorDescription == "Unauthorized")
  }

  @Test func httpServiceErrorRateLimited() {
    let error = HttpServiceError.rateLimited
    #expect(error.errorDescription == "Rate limit exceeded")
  }

  @Test func httpServiceErrorHttpError() {
    let error = HttpServiceError.httpError(statusCode: 500, message: "Internal Server Error")
    #expect(error.errorDescription == "HTTP error (500): Internal Server Error")
  }

  // MARK: - HttpServiceError to ZohoError Conversion

  @Test func httpServiceErrorToZohoErrorInvalidUrl() {
    let httpError = HttpServiceError.invalidUrl
    let zohoError = httpError.toZohoError()
    if case .invalidURL = zohoError {
      // Success
    } else {
      Issue.record("Expected .invalidURL")
    }
  }

  @Test func httpServiceErrorToZohoErrorInvalidResponse() {
    let httpError = HttpServiceError.invalidResponse
    let zohoError = httpError.toZohoError()
    if case .invalidResponse = zohoError {
      // Success
    } else {
      Issue.record("Expected .invalidResponse")
    }
  }

  @Test func httpServiceErrorToZohoErrorUnauthorized() {
    let httpError = HttpServiceError.unauthorized
    let zohoError = httpError.toZohoError()
    if case .unauthorized = zohoError {
      // Success
    } else {
      Issue.record("Expected .unauthorized")
    }
  }

  @Test func httpServiceErrorToZohoErrorRateLimited() {
    let httpError = HttpServiceError.rateLimited
    let zohoError = httpError.toZohoError()
    if case .rateLimited = zohoError {
      // Success
    } else {
      Issue.record("Expected .rateLimited")
    }
  }

  @Test func httpServiceErrorToZohoErrorHttpError() {
    let httpError = HttpServiceError.httpError(statusCode: 403, message: "Forbidden")
    let zohoError = httpError.toZohoError()
    if case let .httpError(statusCode, message) = zohoError {
      #expect(statusCode == 403)
      #expect(message == "Forbidden")
    } else {
      Issue.record("Expected .httpError")
    }
  }
}
