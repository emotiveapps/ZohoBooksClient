import Foundation

/// A client for interacting with the Zoho Books API
public actor ZohoBooksClient<OAuth: OAuthProviding> {
  private let organizationId: String
  private let oauth: OAuth
  private let http: HttpService
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

    // Create HttpService with Zoho's rate limit
    self.http = HttpService(baseURL: self.baseURL, maxRequestsPerMinute: 100, verbose: verbose)
  }

  /// Configure the HTTP service with OAuth auth.
  /// Must be called after init due to actor isolation.
  public func configure() async {
    // Compose OAuth with HttpService
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

  // MARK: - Private helpers wrapping HttpService

  private func get<T: Decodable>(endpoint: String, queryItems: [URLQueryItem] = []) async throws -> T {
    var items = queryItems
    items.append(orgQueryItem)
    do {
      return try await http.get(endpoint: endpoint, queryItems: items)
    } catch let error as HttpServiceError {
      throw error.toZohoError()
    }
  }

  private func post<T: Decodable>(endpoint: String, body: some Encodable) async throws -> T {
    do {
      return try await http.post(endpoint: endpoint, body: body, queryItems: [orgQueryItem])
    } catch let error as HttpServiceError {
      throw error.toZohoError()
    }
  }

  private func put<T: Decodable>(endpoint: String, body: some Encodable) async throws -> T {
    do {
      return try await http.put(endpoint: endpoint, body: body, queryItems: [orgQueryItem])
    } catch let error as HttpServiceError {
      throw error.toZohoError()
    }
  }

  private func postRaw(endpoint: String) async throws {
    do {
      _ = try await http.request(endpoint: endpoint, method: "POST", queryItems: [orgQueryItem])
    } catch let error as HttpServiceError {
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

  /// Fetch expenses filtered by vendor and paid-through account
  /// - Parameters:
  ///   - vendorId: Filter by vendor ID
  ///   - paidThroughAccountId: Filter by the bank/credit card account that paid
  /// - Returns: Array of matching expenses
  public func fetchExpenses(vendorId: String, paidThroughAccountId: String) async throws -> [ZBExpense] {
    var allExpenses: [ZBExpense] = []
    var page = 1
    let perPage = 200

    while true {
      let queryItems = [
        URLQueryItem(name: "vendor_id", value: vendorId),
        URLQueryItem(name: "paid_through_account_id", value: paidThroughAccountId),
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

  /// Upload an attachment to an expense
  public func uploadExpenseAttachment(expenseId: String, fileData: Data, filename: String) async throws {
    do {
      try await http.uploadMultipart(
        endpoint: "/expenses/\(expenseId)/attachment",
        fileData: fileData,
        filename: filename,
        fieldName: "attachment",
        queryItems: [orgQueryItem]
      )
    } catch let error as HttpServiceError {
      throw error.toZohoError()
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

  // MARK: - Bank Accounts

  /// Fetch all bank accounts
  public func fetchBankAccounts() async throws -> [ZBBankAccount] {
    let response: ZBBankAccountListResponse = try await get(endpoint: "/bankaccounts")

    if response.code != 0 {
      throw ZohoError.apiError(code: response.code, message: response.message)
    }

    return response.bankaccounts ?? []
  }

  // MARK: - Bank Transactions

  /// Fetch uncategorized bank transactions
  /// - Parameters:
  ///   - accountId: Bank account ID
  ///   - year: Optional year to filter transactions
  /// - Returns: Array of uncategorized transactions
  public func fetchUncategorizedTransactions(accountId: String, year: Int? = nil) async throws -> [ZBBankTransaction] {
    var allTransactions: [ZBBankTransaction] = []
    var page = 1
    let perPage = 200

    while true {
      var queryItems = [
        URLQueryItem(name: "account_id", value: accountId),
        URLQueryItem(name: "status", value: "uncategorized"),
        URLQueryItem(name: "page", value: "\(page)"),
        URLQueryItem(name: "per_page", value: "\(perPage)")
      ]

      if let year = year {
        queryItems.append(URLQueryItem(name: "date_start", value: "\(year)-01-01"))
        queryItems.append(URLQueryItem(name: "date_end", value: "\(year)-12-31"))
      }

      let response: ZBBankTransactionListResponse = try await get(
        endpoint: "/banktransactions",
        queryItems: queryItems
      )

      if response.code != 0 {
        throw ZohoError.apiError(code: response.code, message: response.message)
      }

      if let transactions = response.banktransactions {
        allTransactions.append(contentsOf: transactions)
      }

      if let pageContext = response.pageContext, pageContext.hasMorePage == true {
        page += 1
      } else {
        break
      }
    }

    return allTransactions
  }

  /// Categorize a bank transaction as an expense
  public func categorizeAsExpense(transactionId: String, request: ZBCategorizeExpenseRequest) async throws {
    let response: ZBCategorizeResponse = try await post(
      endpoint: "/banktransactions/uncategorized/\(transactionId)/categorize/expenses",
      body: request
    )

    if response.code != 0 {
      throw ZohoError.apiError(code: response.code, message: response.message)
    }
  }

  /// Categorize a bank transaction as a transfer between accounts
  public func categorizeAsTransfer(transactionId: String, request: ZBCategorizeTransferRequest) async throws {
    let response: ZBCategorizeResponse = try await post(
      endpoint: "/banktransactions/uncategorized/\(transactionId)/categorize",
      body: request
    )

    if response.code != 0 {
      throw ZohoError.apiError(code: response.code, message: response.message)
    }
  }

  /// Categorize a bank transaction as an owner contribution
  public func categorizeAsOwnerContribution(transactionId: String, request: ZBCategorizeOwnerContributionRequest) async throws {
    let response: ZBCategorizeResponse = try await post(
      endpoint: "/banktransactions/uncategorized/\(transactionId)/categorize",
      body: request
    )

    if response.code != 0 {
      throw ZohoError.apiError(code: response.code, message: response.message)
    }
  }

  /// Categorize a bank transaction as a sale (income without invoice)
  public func categorizeAsSale(transactionId: String, request: ZBCategorizeSaleRequest) async throws {
    let response: ZBCategorizeResponse = try await post(
      endpoint: "/banktransactions/uncategorized/\(transactionId)/categorize",
      body: request
    )

    if response.code != 0 {
      throw ZohoError.apiError(code: response.code, message: response.message)
    }
  }

  // MARK: - Vendor Helpers

  /// Get or create a vendor by name
  /// - Parameter name: Vendor name
  /// - Returns: Existing or newly created vendor
  public func getOrCreateVendor(name: String) async throws -> ZBContact {
    if let existing = try await searchContactByName(name, contactType: "vendor") {
      return existing
    }

    let request = ZBContactCreateRequest(
      contactName: name,
      contactType: "vendor"
    )
    return try await createContact(request)
  }
}

// MARK: - Convenience Initializer for ZohoConfig (backward compatibility)

public extension ZohoBooksClient where OAuth == ZohoOAuth {
  /// Initialize with a ZohoConfig (backward compatible, uses manual token management)
  /// - Parameters:
  ///   - config: Configuration containing credentials and organization info
  ///   - verbose: Whether to print debug information
  init(config: ZohoConfig, verbose: Bool = false) {
    self.init(
      organizationId: config.organizationId,
      oauth: ZohoOAuth(config: config),
      region: config.region,
      verbose: verbose
    )
  }

  /// Access the OAuth manager (for backward compatibility)
  var oauthManager: ZohoOAuth {
    oauth
  }
}

// MARK: - Error Conversion

extension HttpServiceError {
  func toZohoError() -> ZohoError {
    switch self {
    case .invalidUrl:
      return .invalidURL
    case .invalidResponse:
      return .invalidResponse
    case .unauthorized:
      return .unauthorized
    case .rateLimited:
      return .rateLimited
    case let .httpError(statusCode, message):
      return .httpError(statusCode: statusCode, message: message)
    }
  }
}
