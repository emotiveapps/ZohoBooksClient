import XCTest
@testable import ZohoBooksClient

final class FullModelEncodingTests: XCTestCase {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  func testZBInvoiceEncoding() throws {
    let invoice = ZBInvoice(
      invoiceId: "inv-123",
      invoiceNumber: "INV-001",
      customerId: "cust-456",
      customerName: "Acme Corp",
      status: "sent",
      date: "2024-01-15",
      dueDate: "2024-02-15",
      total: 1500.0,
      balance: 1000.0
    )

    let data = try encoder.encode(invoice)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["invoice_id"] as? String, "inv-123")
    XCTAssertEqual(json["invoice_number"] as? String, "INV-001")
    XCTAssertEqual(json["customer_id"] as? String, "cust-456")
    XCTAssertEqual(json["customer_name"] as? String, "Acme Corp")
    XCTAssertEqual(json["status"] as? String, "sent")
    XCTAssertEqual(json["total"] as? Double, 1500.0)
    XCTAssertEqual(json["balance"] as? Double, 1000.0)
  }

  func testZBInvoiceLineItemEncoding() throws {
    let lineItem = ZBInvoiceLineItem(
      lineItemId: "line-123",
      itemId: "item-456",
      name: "Consulting",
      description: "Professional services",
      rate: 150.0,
      quantity: 10.0,
      itemTotal: 1500.0
    )

    let data = try encoder.encode(lineItem)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["line_item_id"] as? String, "line-123")
    XCTAssertEqual(json["item_id"] as? String, "item-456")
    XCTAssertEqual(json["name"] as? String, "Consulting")
    XCTAssertEqual(json["rate"] as? Double, 150.0)
    XCTAssertEqual(json["quantity"] as? Double, 10.0)
    XCTAssertEqual(json["item_total"] as? Double, 1500.0)
  }

  func testZBContactEncoding() throws {
    let contact = ZBContact(
      contactId: "contact-123",
      contactName: "Acme Corp",
      companyName: "Acme Corporation",
      contactType: "customer",
      currencyCode: "USD",
      email: "info@acme.com"
    )

    let data = try encoder.encode(contact)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["contact_id"] as? String, "contact-123")
    XCTAssertEqual(json["contact_name"] as? String, "Acme Corp")
    XCTAssertEqual(json["company_name"] as? String, "Acme Corporation")
    XCTAssertEqual(json["contact_type"] as? String, "customer")
    XCTAssertEqual(json["currency_code"] as? String, "USD")
  }

  func testZBExpenseEncoding() throws {
    let expense = ZBExpense(
      expenseId: "exp-123",
      accountId: "acc-456",
      accountName: "Office Supplies",
      date: "2024-01-20",
      amount: 250.0,
      total: 275.0,
      status: "recorded"
    )

    let data = try encoder.encode(expense)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["expense_id"] as? String, "exp-123")
    XCTAssertEqual(json["account_id"] as? String, "acc-456")
    XCTAssertEqual(json["account_name"] as? String, "Office Supplies")
    XCTAssertEqual(json["amount"] as? Double, 250.0)
    XCTAssertEqual(json["total"] as? Double, 275.0)
  }

  func testZBPaymentEncoding() throws {
    let payment = ZBPayment(
      paymentId: "pay-123",
      customerId: "cust-456",
      customerName: "Acme Corp",
      paymentMode: "Bank Transfer",
      amount: 1000.0,
      date: "2024-01-25"
    )

    let data = try encoder.encode(payment)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["payment_id"] as? String, "pay-123")
    XCTAssertEqual(json["customer_id"] as? String, "cust-456")
    XCTAssertEqual(json["customer_name"] as? String, "Acme Corp")
    XCTAssertEqual(json["payment_mode"] as? String, "Bank Transfer")
    XCTAssertEqual(json["amount"] as? Double, 1000.0)
  }

  func testZBAccountEncoding() throws {
    let account = ZBAccount(
      accountId: "acc-123",
      accountName: "Office Expenses",
      accountCode: "6000",
      accountType: "expense",
      description: "General office expenses",
      isActive: true
    )

    let data = try encoder.encode(account)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["account_id"] as? String, "acc-123")
    XCTAssertEqual(json["account_name"] as? String, "Office Expenses")
    XCTAssertEqual(json["account_code"] as? String, "6000")
    XCTAssertEqual(json["account_type"] as? String, "expense")
    XCTAssertEqual(json["is_active"] as? Bool, true)
  }

  func testZBTaxExemptionEncoding() throws {
    let exemption = ZBTaxExemption(
      taxExemptionId: "exempt-123",
      taxExemptionCode: "EXEMPT-001",
      description: "Non-profit exemption",
      type: "customer"
    )

    let data = try encoder.encode(exemption)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["tax_exemption_id"] as? String, "exempt-123")
    XCTAssertEqual(json["tax_exemption_code"] as? String, "EXEMPT-001")
    XCTAssertEqual(json["description"] as? String, "Non-profit exemption")
    XCTAssertEqual(json["type"] as? String, "customer")
  }
}
