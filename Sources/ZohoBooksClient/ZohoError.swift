import Foundation

/// Errors that can occur when interacting with the Zoho Books API
public enum ZohoError: Error, LocalizedError, Sendable {
  case invalidURL
  case invalidResponse
  case unauthorized
  case rateLimited
  case httpError(statusCode: Int, message: String)
  case apiError(code: Int, message: String)
  case decodingError(Error)
  case networkError(Error)
  case tokenRefreshFailed(String)

  public var errorDescription: String? {
    switch self {
    case .invalidURL:
      return "Invalid Zoho Books API URL"
    case .invalidResponse:
      return "Invalid API response"
    case .unauthorized:
      return "Unauthorized - access token may be expired"
    case .rateLimited:
      return "Rate limit exceeded - too many requests"
    case let .httpError(statusCode, message):
      return "HTTP error (\(statusCode)): \(message)"
    case let .apiError(code, message):
      return "Zoho API error (\(code)): \(message)"
    case let .decodingError(error):
      return "Failed to decode response: \(error.localizedDescription)"
    case let .networkError(error):
      return "Network error: \(error.localizedDescription)"
    case let .tokenRefreshFailed(message):
      return "Token refresh failed: \(message)"
    }
  }
}
