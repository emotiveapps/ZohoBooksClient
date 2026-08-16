import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct ZohoBooksClientTests {
  @Test func zohoConfigInitialization() {
    let config = ZohoConfig(
      clientId: "test-client-id",
      clientSecret: "test-client-secret",
      accessToken: "test-access-token",
      refreshToken: "test-refresh-token",
      organizationId: "test-org-id",
      region: .com
    )

    #expect(config.clientId == "test-client-id")
    #expect(config.organizationId == "test-org-id")
    #expect(config.baseURL == "https://www.zohoapis.com/books/v3")
    #expect(config.oauthURL == "https://accounts.zoho.com/oauth/v2/token")
  }

  @Test func zohoConfigRegions() {
    let euConfig = ZohoConfig(
      clientId: "id",
      clientSecret: "secret",
      accessToken: "token",
      refreshToken: "refresh",
      organizationId: "org",
      region: .europe
    )
    #expect(euConfig.baseURL == "https://www.zohoapis.eu/books/v3")

    let inConfig = ZohoConfig(
      clientId: "id",
      clientSecret: "secret",
      accessToken: "token",
      refreshToken: "refresh",
      organizationId: "org",
      region: .india
    )
    #expect(inConfig.baseURL == "https://www.zohoapis.in/books/v3")
  }

  @Test func contactCreateRequest() {
    let request = ZBContactCreateRequest(
      contactName: "Test Company",
      companyName: "Test Company Inc.",
      contactType: ZBContactType.customer.rawValue
    )

    #expect(request.contactName == "Test Company")
    #expect(request.contactType == "customer")
  }

  @Test func invoiceLineItemRequest() {
    let lineItem = ZBInvoiceLineItemRequest(
      name: "Consulting",
      description: "Development work",
      rate: 150.0,
      quantity: 10.0
    )

    #expect(lineItem.name == "Consulting")
    #expect(lineItem.rate == 150.0)
    #expect(lineItem.quantity == 10.0)
  }

  @Test func expenseCreateRequest() {
    let expense = ZBExpenseCreateRequest(
      accountId: "account-123",
      date: "2024-01-15",
      amount: 250.50,
      description: "Office supplies"
    )

    #expect(expense.accountId == "account-123")
    #expect(expense.amount == 250.50)
  }

  @Test func paymentInvoice() {
    let paymentInvoice = ZBPaymentInvoice(
      invoiceId: "inv-123",
      amountApplied: 500.0
    )

    #expect(paymentInvoice.invoiceId == "inv-123")
    #expect(paymentInvoice.amountApplied == 500.0)
  }

  @Test func accountTypes() {
    #expect(ZBAccountType.expense.rawValue == "expense")
    #expect(ZBAccountType.income.rawValue == "income")
    #expect(ZBAccountType.bank.rawValue == "bank")
    #expect(ZBAccountType.creditCard.rawValue == "credit_card")
  }
}
