import XCTest
@testable import ZohoBooksClient

final class ZohoBooksClientTests: XCTestCase {
  func testZohoConfigInitialization() {
    let config = ZohoConfig(
      clientId: "test-client-id",
      clientSecret: "test-client-secret",
      accessToken: "test-access-token",
      refreshToken: "test-refresh-token",
      organizationId: "test-org-id",
      region: .com
    )

    XCTAssertEqual(config.clientId, "test-client-id")
    XCTAssertEqual(config.organizationId, "test-org-id")
    XCTAssertEqual(config.baseURL, "https://www.zohoapis.com/books/v3")
    XCTAssertEqual(config.oauthURL, "https://accounts.zoho.com/oauth/v2/token")
  }

  func testZohoConfigRegions() {
    let euConfig = ZohoConfig(
      clientId: "id",
      clientSecret: "secret",
      accessToken: "token",
      refreshToken: "refresh",
      organizationId: "org",
      region: .europe
    )
    XCTAssertEqual(euConfig.baseURL, "https://www.zohoapis.eu/books/v3")

    let inConfig = ZohoConfig(
      clientId: "id",
      clientSecret: "secret",
      accessToken: "token",
      refreshToken: "refresh",
      organizationId: "org",
      region: .india
    )
    XCTAssertEqual(inConfig.baseURL, "https://www.zohoapis.in/books/v3")
  }

  func testContactCreateRequest() {
    let request = ZBContactCreateRequest(
      contactName: "Test Company",
      companyName: "Test Company Inc.",
      contactType: ZBContactType.customer.rawValue
    )

    XCTAssertEqual(request.contactName, "Test Company")
    XCTAssertEqual(request.contactType, "customer")
  }

  func testInvoiceLineItemRequest() {
    let lineItem = ZBInvoiceLineItemRequest(
      name: "Consulting",
      description: "Development work",
      rate: 150.0,
      quantity: 10.0
    )

    XCTAssertEqual(lineItem.name, "Consulting")
    XCTAssertEqual(lineItem.rate, 150.0)
    XCTAssertEqual(lineItem.quantity, 10.0)
  }

  func testExpenseCreateRequest() {
    let expense = ZBExpenseCreateRequest(
      accountId: "account-123",
      date: "2024-01-15",
      amount: 250.50,
      description: "Office supplies"
    )

    XCTAssertEqual(expense.accountId, "account-123")
    XCTAssertEqual(expense.amount, 250.50)
  }

  func testPaymentInvoice() {
    let paymentInvoice = ZBPaymentInvoice(
      invoiceId: "inv-123",
      amountApplied: 500.0
    )

    XCTAssertEqual(paymentInvoice.invoiceId, "inv-123")
    XCTAssertEqual(paymentInvoice.amountApplied, 500.0)
  }

  func testAccountTypes() {
    XCTAssertEqual(ZBAccountType.expense.rawValue, "expense")
    XCTAssertEqual(ZBAccountType.income.rawValue, "income")
    XCTAssertEqual(ZBAccountType.bank.rawValue, "bank")
    XCTAssertEqual(ZBAccountType.creditCard.rawValue, "credit_card")
  }
}
