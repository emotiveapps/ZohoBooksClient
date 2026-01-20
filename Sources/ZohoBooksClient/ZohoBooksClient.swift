import Foundation

/// A client for interacting with the Zoho Books API
public actor ZohoBooksClient<OAuth: OAuthProviding> {
    private let organizationId: String
    private let oauth: OAuth
    private let http: HTTPService
    private let verbose: Bool
    private let baseURL: String

    /// Initialize the Zoho Books client with any OAuth provider
    /// - Parameters:
    ///   - organizationId: Your Zoho Books organization ID
    ///   - oauth: An OAuth provider conforming to OAuthProviding
    ///   - region: Zoho data center region
    ///   - verbose: Whether to print debug information
    public init(
        organizationId: String,
        oauth: OAuth,
        region: ZohoRegion = .com,
        verbose: Bool = false
    ) {
        self.organizationId = organizationId
        self.oauth = oauth
        self.verbose = verbose
        self.baseURL = "https://www.zohoapis.\(region.rawValue)/books/v3"

        // Create HTTPService with Zoho's rate limit
        self.http = HTTPService(baseURL: self.baseURL, maxRequestsPerMinute: 100, verbose: verbose)
    }

    /// Configure the HTTP service with OAuth auth.
    /// Must be called after init due to actor isolation.
    public func configure() async {
        // Compose OAuth with HTTPService
        await http.setAuthorizationHeader { [oauth] in
            let token = await oauth.currentAccessToken
            return (name: "Authorization", value: "Zoho-oauthtoken \(token)")
        }

        await http.setOnUnauthorized { [oauth] in
            try await oauth.refreshAccessToken()
        }
    }

    /// Access the OAuth provider
    public var oauthProvider: OAuth {
        oauth
    }

    // MARK: - Zoho-specific query params

    private var orgQueryItem: URLQueryItem {
        URLQueryItem(name: "organization_id", value: organizationId)
    }

    // MARK: - Private helpers wrapping HTTPService

    private func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
        var items = queryItems
        items.append(orgQueryItem)
        do {
            return try await http.get(endpoint: endpoint, queryItems: items)
        } catch let error as HTTPServiceError {
            throw error.toZohoError()
        }
    }

    private func post<T: Decodable, R: Encodable>(endpoint: String, body: R) async throws -> T {
        do {
            return try await http.post(endpoint: endpoint, body: body, queryItems: [orgQueryItem])
        } catch let error as HTTPServiceError {
            throw error.toZohoError()
        }
    }

    private func put<T: Decodable, R: Encodable>(endpoint: String, body: R) async throws -> T {
        do {
            return try await http.put(endpoint: endpoint, body: body, queryItems: [orgQueryItem])
        } catch let error as HTTPServiceError {
            throw error.toZohoError()
        }
    }

    private func postRaw(endpoint: String) async throws {
        do {
            _ = try await http.request(endpoint: endpoint, method: "POST", queryItems: [orgQueryItem])
        } catch let error as HTTPServiceError {
            throw error.toZohoError()
        }
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
            var queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
            if let type = contactType {
                queryItems.append(URLQueryItem(name: "contact_type", value: type))
            }

            let response: ZBContactListResponse = try await get(endpoint: "/contacts", queryItems: queryItems)

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
        try await postRaw(endpoint: "/invoices/\(invoiceId)/status/sent")
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
            let queryItems = [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)")
            ]
            let response: ZBExpenseListResponse = try await get(endpoint: "/expenses", queryItems: queryItems)

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

    /// Upload an attachment to an expense (multipart form-data, handled separately)
    public func uploadExpenseAttachment(expenseId: String, fileData: Data, filename: String) async throws {
        // Multipart upload requires custom handling outside HTTPService
        let token = await oauth.currentAccessToken
        try await uploadMultipart(
            endpoint: "/expenses/\(expenseId)/attachment",
            fileData: fileData,
            filename: filename,
            fieldName: "attachment",
            token: token
        )
    }

    /// Multipart form-data upload (Zoho-specific)
    private func uploadMultipart(
        endpoint: String,
        fileData: Data,
        filename: String,
        fieldName: String,
        token: String,
        retryOnAuth: Bool = true
    ) async throws {
        var components = URLComponents(string: "\(baseURL)\(endpoint)")!
        components.queryItems = [orgQueryItem]

        guard let url = components.url else {
            throw ZohoError.invalidURL
        }

        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Zoho-oauthtoken \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType(for: filename))\r\n\r\n".data(using: .utf8)!)
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

        if httpResponse.statusCode == 401 && retryOnAuth {
            try await oauth.refreshAccessToken()
            let newToken = await oauth.currentAccessToken
            return try await uploadMultipart(
                endpoint: endpoint,
                fileData: fileData,
                filename: filename,
                fieldName: fieldName,
                token: newToken,
                retryOnAuth: false
            )
        }

        if httpResponse.statusCode == 429 {
            if verbose {
                print("Rate limited, waiting 60 seconds...")
            }
            try await Task.sleep(nanoseconds: 60_000_000_000)
            return try await uploadMultipart(
                endpoint: endpoint,
                fileData: fileData,
                filename: filename,
                fieldName: fieldName,
                token: token,
                retryOnAuth: retryOnAuth
            )
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

// MARK: - Convenience Initializer for ZohoConfig (backward compatibility)

extension ZohoBooksClient where OAuth == ZohoOAuth {
    /// Initialize with a ZohoConfig (backward compatible, uses manual token management)
    /// - Parameters:
    ///   - config: Configuration containing credentials and organization info
    ///   - verbose: Whether to print debug information
    public init(config: ZohoConfig, verbose: Bool = false) {
        self.init(
            organizationId: config.organizationId,
            oauth: ZohoOAuth(config: config),
            region: config.region,
            verbose: verbose
        )
    }

    /// Access the OAuth manager (for backward compatibility)
    public var oauthManager: ZohoOAuth {
        oauth
    }
}

// MARK: - Error Conversion

extension HTTPServiceError {
    func toZohoError() -> ZohoError {
        switch self {
        case .invalidURL:
            return .invalidURL
        case .invalidResponse:
            return .invalidResponse
        case .unauthorized:
            return .unauthorized
        case .rateLimited:
            return .rateLimited
        case .httpError(let statusCode, let message):
            return .httpError(statusCode: statusCode, message: message)
        }
    }
}
