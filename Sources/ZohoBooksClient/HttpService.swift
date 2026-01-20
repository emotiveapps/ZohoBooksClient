import Foundation
import MimeTypeEnum

/// A generic HTTP service with rate limiting and retry support.
/// Auth is composable via closures, not tightly coupled.
public actor HttpService {
  private let baseURL: String
  private let verbose: Bool

  // Rate limiting
  private var requestTimestamps: [Date] = []
  private let maxRequestsPerMinute: Int

  /// Closure that provides the authorization header. Return nil for no auth.
  public var authorizationHeader: (@Sendable () async -> (name: String, value: String)?)?

  /// Called when a 401 Unauthorized response is received. Use this to refresh tokens.
  /// If this succeeds, the request will be retried automatically.
  public var onUnauthorized: (@Sendable () async throws -> Void)?

  public init(baseURL: String, maxRequestsPerMinute: Int = 100, verbose: Bool = false) {
    self.baseURL = baseURL
    self.maxRequestsPerMinute = maxRequestsPerMinute
    self.verbose = verbose
  }

  /// Get the base URL (for custom request building)
  public func getBaseURL() -> String {
    baseURL
  }

  /// Set the authorization header provider
  public func setAuthorizationHeader(_ provider: @escaping @Sendable () async -> (name: String, value: String)?) {
    self.authorizationHeader = provider
  }

  /// Set the unauthorized handler (called on 401 responses)
  public func setOnUnauthorized(_ handler: @escaping @Sendable () async throws -> Void) {
    self.onUnauthorized = handler
  }

  // MARK: - Rate Limiting

  private func checkRateLimit() async {
    let now = Date()
    let oneMinuteAgo = now.addingTimeInterval(-60)

    requestTimestamps = requestTimestamps.filter { $0 > oneMinuteAgo }

    if requestTimestamps.count >= maxRequestsPerMinute {
      if let oldestRequest = requestTimestamps.first {
        let waitTime = 60 - now.timeIntervalSince(oldestRequest)
        if waitTime > 0 {
          if verbose {
            print("Rate limit approaching, waiting \(Int(waitTime)) seconds...")
          }
          try? await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
        }
      }
    }

    requestTimestamps.append(now)
  }

  // MARK: - Request Methods

  /// Perform an HTTP request
  /// - Parameters:
  ///   - endpoint: The API endpoint (appended to baseURL)
  ///   - method: HTTP method (GET, POST, PUT, DELETE, etc.)
  ///   - queryItems: Additional query parameters
  ///   - body: Optional request body data
  ///   - headers: Additional headers to include
  ///   - retryOnAuth: Whether to retry after refreshing auth on 401
  /// - Returns: Response data
  public func request(
    endpoint: String,
    method: String = "GET",
    queryItems: [URLQueryItem] = [],
    body: Data? = nil,
    headers: [String: String] = [:],
    retryOnAuth: Bool = true
  ) async throws -> Data {
    await checkRateLimit()

    guard var components = URLComponents(string: "\(baseURL)\(endpoint)") else {
      throw HttpServiceError.invalidUrl
    }

    // Merge query items
    var allQueryItems = components.queryItems ?? []
    allQueryItems.append(contentsOf: queryItems)
    if !allQueryItems.isEmpty {
      components.queryItems = allQueryItems
    }

    guard let url = components.url else {
      throw HttpServiceError.invalidUrl
    }

    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

    // Apply custom headers
    for (name, value) in headers {
      request.setValue(value, forHTTPHeaderField: name)
    }

    // Apply authorization header if provided
    if let authHeader = await authorizationHeader?() {
      request.setValue(authHeader.value, forHTTPHeaderField: authHeader.name)
    }

    if let body {
      request.httpBody = body
    }

    if verbose {
      print("  \(method) \(url.absoluteString)")
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HttpServiceError.invalidResponse
    }

    // Handle 401 - call onUnauthorized and retry if provided
    if httpResponse.statusCode == 401 && retryOnAuth {
      if let refreshAuth = onUnauthorized {
        try await refreshAuth()
        return try await self.request(
          endpoint: endpoint,
          method: method,
          queryItems: queryItems,
          body: body,
          headers: headers,
          retryOnAuth: false
        )
      }
      throw HttpServiceError.unauthorized
    }

    // Handle 429 - rate limited, wait and retry
    if httpResponse.statusCode == 429 {
      if verbose {
        print("Rate limited, waiting 60 seconds...")
      }
      try await Task.sleep(nanoseconds: 60_000_000_000)
      return try await self.request(
        endpoint: endpoint,
        method: method,
        queryItems: queryItems,
        body: body,
        headers: headers,
        retryOnAuth: retryOnAuth
      )
    }

    guard (200 ... 299).contains(httpResponse.statusCode) else {
      let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw HttpServiceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
    }

    return data
  }

  // MARK: - Convenience Methods

  /// Perform a GET request and decode the response
  public func get<T: Decodable>(
    endpoint: String,
    queryItems: [URLQueryItem] = [],
    headers: [String: String] = [:]
  ) async throws -> T {
    let data = try await request(endpoint: endpoint, queryItems: queryItems, headers: headers)
    return try JSONDecoder().decode(T.self, from: data)
  }

  /// Perform a POST request with an encodable body and decode the response
  public func post<T: Decodable>(
    endpoint: String,
    body: some Encodable,
    queryItems: [URLQueryItem] = [],
    headers: [String: String] = [:]
  ) async throws -> T {
    let bodyData = try JSONEncoder().encode(body)
    let data = try await request(
      endpoint: endpoint, method: "POST",
      queryItems: queryItems, body: bodyData, headers: headers)
    return try JSONDecoder().decode(T.self, from: data)
  }

  /// Perform a PUT request with an encodable body and decode the response
  public func put<T: Decodable>(
    endpoint: String,
    body: some Encodable,
    queryItems: [URLQueryItem] = [],
    headers: [String: String] = [:]
  ) async throws -> T {
    let bodyData = try JSONEncoder().encode(body)
    let data = try await request(
      endpoint: endpoint, method: "PUT",
      queryItems: queryItems, body: bodyData, headers: headers)
    return try JSONDecoder().decode(T.self, from: data)
  }

  /// Perform a DELETE request
  public func delete(
    endpoint: String,
    queryItems: [URLQueryItem] = [],
    headers: [String: String] = [:]
  ) async throws -> Data {
    return try await request(endpoint: endpoint, method: "DELETE", queryItems: queryItems, headers: headers)
  }

  // MARK: - Multipart Upload

  /// Upload a file using multipart/form-data
  /// - Parameters:
  ///   - endpoint: The API endpoint
  ///   - fileData: The file data to upload
  ///   - filename: The filename to use in the form
  ///   - fieldName: The form field name for the file
  ///   - queryItems: Additional query parameters
  ///   - additionalFields: Additional form fields (non-file)
  ///   - retryOnAuth: Whether to retry after refreshing auth on 401
  /// - Returns: Response data
  @discardableResult
  public func uploadMultipart(
    endpoint: String,
    fileData: Data,
    filename: String,
    fieldName: String = "file",
    queryItems: [URLQueryItem] = [],
    additionalFields: [String: String] = [:],
    retryOnAuth: Bool = true
  ) async throws -> Data {
    await checkRateLimit()

    guard var components = URLComponents(string: "\(baseURL)\(endpoint)") else {
      throw HttpServiceError.invalidUrl
    }
    if !queryItems.isEmpty {
      components.queryItems = queryItems
    }

    guard let url = components.url else {
      throw HttpServiceError.invalidUrl
    }

    let boundary = "Boundary-\(UUID().uuidString)"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

    // Apply authorization header if provided
    if let authHeader = await authorizationHeader?() {
      request.setValue(authHeader.value, forHTTPHeaderField: authHeader.name)
    }

    // Build multipart body
    var body = Data()

    // Add additional form fields
    for (name, value) in additionalFields {
      body.append(Data("--\(boundary)\r\n".utf8))
      body.append(Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8))
      body.append(Data("\(value)\r\n".utf8))
    }

    // Add file data
    body.append(Data("--\(boundary)\r\n".utf8))
    let contentDisposition = "Content-Disposition: form-data; "
      + "name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n"
    body.append(Data(contentDisposition.utf8))
    body.append(Data("Content-Type: \(MimeType.mimeTypeString(for: filename))\r\n\r\n".utf8))
    body.append(fileData)
    body.append(Data("\r\n--\(boundary)--\r\n".utf8))

    request.httpBody = body

    if verbose {
      print("  POST \(url.absoluteString) (uploading \(filename), \(fileData.count) bytes)")
    }

    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse else {
      throw HttpServiceError.invalidResponse
    }

    // Handle 401 - call onUnauthorized and retry if provided
    if httpResponse.statusCode == 401 && retryOnAuth {
      if let refreshAuth = onUnauthorized {
        try await refreshAuth()
        return try await self.uploadMultipart(
          endpoint: endpoint,
          fileData: fileData,
          filename: filename,
          fieldName: fieldName,
          queryItems: queryItems,
          additionalFields: additionalFields,
          retryOnAuth: false
        )
      }
      throw HttpServiceError.unauthorized
    }

    // Handle 429 - rate limited, wait and retry
    if httpResponse.statusCode == 429 {
      if verbose {
        print("Rate limited, waiting 60 seconds...")
      }
      try await Task.sleep(nanoseconds: 60_000_000_000)
      return try await self.uploadMultipart(
        endpoint: endpoint,
        fileData: fileData,
        filename: filename,
        fieldName: fieldName,
        queryItems: queryItems,
        additionalFields: additionalFields,
        retryOnAuth: retryOnAuth
      )
    }

    guard (200 ... 299).contains(httpResponse.statusCode) else {
      let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
      throw HttpServiceError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
    }

    return data
  }
}

// MARK: - Errors

/// Errors from HttpService (generic, not API-specific)
public enum HttpServiceError: Error, LocalizedError, Sendable {
  case invalidUrl
  case invalidResponse
  case unauthorized
  case rateLimited
  case httpError(statusCode: Int, message: String)

  public var errorDescription: String? {
    switch self {
    case .invalidUrl:
      return "Invalid URL"
    case .invalidResponse:
      return "Invalid response"
    case .unauthorized:
      return "Unauthorized"
    case .rateLimited:
      return "Rate limit exceeded"
    case let .httpError(statusCode, message):
      return "HTTP error (\(statusCode)): \(message)"
    }
  }
}
