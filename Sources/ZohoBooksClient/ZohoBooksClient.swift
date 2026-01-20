import Foundation

/// A client for interacting with the Zoho Books API
public actor ZohoBooksClient {
    private let baseURL: String
    private let organizationId: String
    private let oauth: ZohoOAuth
    private let verbose: Bool

    // Rate limiting
    private var requestTimestamps: [Date] = []
    private let maxRequestsPerMinute = 100

    /// Initialize the Zoho Books client
    /// - Parameters:
    ///   - config: Configuration containing credentials and organization info
    ///   - verbose: Whether to print debug information
    public init(config: ZohoConfig, verbose: Bool = false) {
        self.baseURL = config.baseURL
        self.organizationId = config.organizationId
        self.oauth = ZohoOAuth(config: config)
        self.verbose = verbose
    }

    /// Access the OAuth manager for token operations
    public var oauthManager: ZohoOAuth {
        oauth
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

    // MARK: - HTTP Request Helpers

    private func makeRequest(
        endpoint: String,
        method: String = "GET",
        body: Data? = nil,
        retryOnAuth: Bool = true
    ) async throws -> Data {
        await checkRateLimit()

        var components = URLComponents(string: "\(baseURL)\(endpoint)")!

        // Append organization_id to existing query items
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "organization_id", value: organizationId))
        components.queryItems = queryItems

        guard let url = components.url else {
            throw ZohoError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method

        let token = await oauth.currentAccessToken
        request.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let body = body {
            request.httpBody = body
        }

        if verbose {
            print("  \(method) \(url.absoluteString)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ZohoError.networkError(NSError(domain: "ZohoBooks", code: -1))
        }

        // Handle 401 - try to refresh token
        if httpResponse.statusCode == 401 && retryOnAuth {
            try await oauth.refreshAccessToken()
            return try await makeRequest(endpoint: endpoint, method: method, body: body, retryOnAuth: false)
        }

        // Handle 429 - rate limited, wait and retry
        if httpResponse.statusCode == 429 {
            if verbose {
                print("Rate limited, waiting 60 seconds...")
            }
            try await Task.sleep(nanoseconds: 60_000_000_000)
            return try await makeRequest(endpoint: endpoint, method: method, body: body, retryOnAuth: retryOnAuth)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ZohoError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        return data
    }

    private func get<T: Decodable>(endpoint: String) async throws -> T {
        let data = try await makeRequest(endpoint: endpoint)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func post<T: Decodable, R: Encodable>(endpoint: String, body: R) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let data = try await makeRequest(endpoint: endpoint, method: "POST", body: bodyData)
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func put<T: Decodable, R: Encodable>(endpoint: String, body: R) async throws -> T {
        let bodyData = try JSONEncoder().encode(body)
        let data = try await makeRequest(endpoint: endpoint, method: "PUT", body: bodyData)
        return try JSONDecoder().decode(T.self, from: data)
    }

    // MARK: - Contacts

    /// Fetch all contacts with optional filtering by type
    /// - Parameter contactType: Filter by "customer" or "vendor"
    /// - Returns: Array of contacts
    public func fetchContacts(contactType: String? = nil) async throws -> [ZBContact] {
        var allContacts: [ZBContact] = []
        var page = 1
        let perPage = 200

        while true {
            var endpoint = "/contacts?page=\(page)&per_page=\(perPage)"
            if let type = contactType {
                endpoint += "&contact_type=\(type)"
            }

            let response: ZBContactListResponse = try await get(endpoint: endpoint)

            if let contacts = response.contacts {
                allContacts.append(contentsOf: contacts)
            }

            if let pageContext = response.pageContext, pageContext.hasMorePage == true {
                page += 1
            } else {
                break
            }
        }

        return allContacts
    }

    /// Create a new contact
    public func createContact(_ contact: ZBContactCreateRequest) async throws -> ZBContact {
        let response: ZBContactResponse = try await post(endpoint: "/contacts", body: contact)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.contact else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Search for a contact by exact name match
    public func searchContactByName(_ name: String, contactType: String? = nil) async throws -> ZBContact? {
        let contacts = try await fetchContacts(contactType: contactType)
        return contacts.first { ($0.contactName ?? "").lowercased() == name.lowercased() }
    }

    // MARK: - Invoices

    /// Fetch all invoices
    public func fetchInvoices() async throws -> [ZBInvoice] {
        let response: ZBInvoiceListResponse = try await get(endpoint: "/invoices")
        return response.invoices ?? []
    }

    /// Create a new invoice
    public func createInvoice(_ invoice: ZBInvoiceCreateRequest) async throws -> ZBInvoice {
        let response: ZBInvoiceResponse = try await post(endpoint: "/invoices", body: invoice)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.invoice else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Mark an invoice as sent without sending an email
    public func markInvoiceAsSent(_ invoiceId: String) async throws {
        _ = try await makeRequest(endpoint: "/invoices/\(invoiceId)/status/sent", method: "POST")
    }

    /// Search for an invoice by invoice number
    public func searchInvoiceByNumber(_ invoiceNumber: String) async throws -> ZBInvoice? {
        let invoices = try await fetchInvoices()
        return invoices.first { $0.invoiceNumber == invoiceNumber }
    }

    // MARK: - Expenses

    /// Fetch all expenses with pagination
    public func fetchExpenses() async throws -> [ZBExpense] {
        var allExpenses: [ZBExpense] = []
        var page = 1
        let perPage = 200

        while true {
            let endpoint = "/expenses?page=\(page)&per_page=\(perPage)"
            let response: ZBExpenseListResponse = try await get(endpoint: endpoint)

            if let expenses = response.expenses {
                allExpenses.append(contentsOf: expenses)
            }

            if let pageContext = response.pageContext, pageContext.hasMorePage == true {
                page += 1
            } else {
                break
            }
        }

        return allExpenses
    }

    /// Create a new expense
    public func createExpense(_ expense: ZBExpenseCreateRequest) async throws -> ZBExpense {
        let response: ZBExpenseResponse = try await post(endpoint: "/expenses", body: expense)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.expense else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Upload an attachment to an expense
    public func uploadExpenseAttachment(expenseId: String, fileData: Data, filename: String) async throws {
        await checkRateLimit()

        var components = URLComponents(string: "\(baseURL)/expenses/\(expenseId)/attachment")!
        components.queryItems = [URLQueryItem(name: "organization_id", value: organizationId)]

        guard let url = components.url else {
            throw ZohoError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let token = await oauth.currentAccessToken
        request.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Build multipart body
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"attachment\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)

        // Determine content type from filename
        let contentType = mimeType(for: filename)
        body.append("Content-Type: \(contentType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        if verbose {
            print("    POST \(url.absoluteString) (uploading \(filename), \(fileData.count) bytes)")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ZohoError.networkError(NSError(domain: "ZohoBooks", code: -1))
        }

        if httpResponse.statusCode == 401 {
            try await oauth.refreshAccessToken()
            return try await uploadExpenseAttachment(expenseId: expenseId, fileData: fileData, filename: filename)
        }

        if httpResponse.statusCode == 429 {
            if verbose {
                print("Rate limited, waiting 60 seconds...")
            }
            try await Task.sleep(nanoseconds: 60_000_000_000)
            return try await uploadExpenseAttachment(expenseId: expenseId, fileData: fileData, filename: filename)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw ZohoError.httpError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
    }

    private func mimeType(for filename: String) -> String {
        let lowercased = filename.lowercased()
        if lowercased.hasSuffix(".jpg") || lowercased.hasSuffix(".jpeg") {
            return "image/jpeg"
        } else if lowercased.hasSuffix(".png") {
            return "image/png"
        } else if lowercased.hasSuffix(".gif") {
            return "image/gif"
        } else if lowercased.hasSuffix(".pdf") {
            return "application/pdf"
        } else if lowercased.hasSuffix(".webp") {
            return "image/webp"
        } else if lowercased.hasSuffix(".heic") {
            return "image/heic"
        } else {
            return "application/octet-stream"
        }
    }

    // MARK: - Payments

    /// Fetch all customer payments
    public func fetchPayments() async throws -> [ZBPayment] {
        let response: ZBPaymentListResponse = try await get(endpoint: "/customerpayments")
        return response.customerpayments ?? []
    }

    /// Create a new customer payment
    public func createPayment(_ payment: ZBPaymentCreateRequest) async throws -> ZBPayment {
        let response: ZBPaymentResponse = try await post(endpoint: "/customerpayments", body: payment)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.payment else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    // MARK: - Chart of Accounts

    /// Fetch all accounts in the chart of accounts
    public func fetchAccounts() async throws -> [ZBAccount] {
        let response: ZBAccountListResponse = try await get(endpoint: "/chartofaccounts")
        return response.chartOfAccounts ?? []
    }

    /// Create a new account
    public func createAccount(_ account: ZBAccountCreateRequest) async throws -> ZBAccount {
        let response: ZBAccountResponse = try await post(endpoint: "/chartofaccounts", body: account)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.chartOfAccount else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Update an existing account
    public func updateAccount(_ accountId: String, request: ZBAccountUpdateRequest) async throws -> ZBAccount {
        let response: ZBAccountResponse = try await put(endpoint: "/chartofaccounts/\(accountId)", body: request)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let updated = response.chartOfAccount else {
            throw ZohoError.invalidResponse
        }

        return updated
    }

    /// Search for an account by name
    public func searchAccountByName(_ name: String) async throws -> ZBAccount? {
        let accounts = try await fetchAccounts()
        return accounts.first { ($0.accountName ?? "").lowercased() == name.lowercased() }
    }

    // MARK: - Items

    /// Fetch all items
    public func fetchItems() async throws -> [ZBItem] {
        let response: ZBItemListResponse = try await get(endpoint: "/items")
        return response.items ?? []
    }

    /// Create a new item
    public func createItem(_ item: ZBItemCreateRequest) async throws -> ZBItem {
        let response: ZBItemResponse = try await post(endpoint: "/items", body: item)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.item else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Search for an item by name
    public func searchItemByName(_ name: String) async throws -> ZBItem? {
        let items = try await fetchItems()
        return items.first { $0.name.lowercased() == name.lowercased() }
    }

    // MARK: - Taxes

    /// Fetch all taxes
    public func fetchTaxes() async throws -> [ZBTax] {
        let response: ZBTaxListResponse = try await get(endpoint: "/settings/taxes")
        return response.taxes ?? []
    }

    /// Create a new tax
    public func createTax(_ tax: ZBTaxCreateRequest) async throws -> ZBTax {
        let response: ZBTaxResponse = try await post(endpoint: "/settings/taxes", body: tax)

        if response.code != 0 {
            throw ZohoError.apiError(code: response.code, message: response.message)
        }

        guard let created = response.tax else {
            throw ZohoError.invalidResponse
        }

        return created
    }

    /// Fetch all tax exemptions
    public func fetchTaxExemptions() async throws -> [ZBTaxExemption] {
        let response: ZBTaxExemptionListResponse = try await get(endpoint: "/settings/taxexemptions")
        return response.taxExemptions ?? []
    }

    /// Search for a tax by name
    public func searchTaxByName(_ name: String) async throws -> ZBTax? {
        let taxes = try await fetchTaxes()
        return taxes.first { ($0.taxName ?? "").lowercased() == name.lowercased() }
    }

    /// Find a service-related tax exemption
    public func getServiceTaxExemption() async throws -> ZBTaxExemption? {
        let exemptions = try await fetchTaxExemptions()
        return exemptions.first {
            ($0.taxExemptionCode ?? "").lowercased().contains("service") ||
            ($0.description ?? "").lowercased().contains("service")
        }
    }
}
