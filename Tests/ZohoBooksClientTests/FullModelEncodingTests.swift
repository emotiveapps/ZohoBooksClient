import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct FullModelEncodingTests {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  @Test func zBInvoiceEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["invoice_id"] as? String == "inv-123")
    #expect(json["invoice_number"] as? String == "INV-001")
    #expect(json["customer_id"] as? String == "cust-456")
    #expect(json["customer_name"] as? String == "Acme Corp")
    #expect(json["status"] as? String == "sent")
    #expect(json["total"] as? Double == 1500.0)
    #expect(json["balance"] as? Double == 1000.0)
  }

  @Test func zBInvoiceLineItemEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["line_item_id"] as? String == "line-123")
    #expect(json["item_id"] as? String == "item-456")
    #expect(json["name"] as? String == "Consulting")
    #expect(json["rate"] as? Double == 150.0)
    #expect(json["quantity"] as? Double == 10.0)
    #expect(json["item_total"] as? Double == 1500.0)
  }

  @Test func zBContactEncoding() throws {
    let contact = ZBContact(
      contactId: "contact-123",
      contactName: "Acme Corp",
      companyName: "Acme Corporation",
      contactType: "customer",
      currencyCode: "USD",
      email: "info@acme.com"
    )

    let data = try encoder.encode(contact)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["contact_id"] as? String == "contact-123")
    #expect(json["contact_name"] as? String == "Acme Corp")
    #expect(json["company_name"] as? String == "Acme Corporation")
    #expect(json["contact_type"] as? String == "customer")
    #expect(json["currency_code"] as? String == "USD")
  }

  @Test func zBExpenseEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["expense_id"] as? String == "exp-123")
    #expect(json["account_id"] as? String == "acc-456")
    #expect(json["account_name"] as? String == "Office Supplies")
    #expect(json["amount"] as? Double == 250.0)
    #expect(json["total"] as? Double == 275.0)
  }

  @Test func zBPaymentEncoding() throws {
    let payment = ZBPayment(
      paymentId: "pay-123",
      customerId: "cust-456",
      customerName: "Acme Corp",
      paymentMode: "Bank Transfer",
      amount: 1000.0,
      date: "2024-01-25"
    )

    let data = try encoder.encode(payment)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["payment_id"] as? String == "pay-123")
    #expect(json["customer_id"] as? String == "cust-456")
    #expect(json["customer_name"] as? String == "Acme Corp")
    #expect(json["payment_mode"] as? String == "Bank Transfer")
    #expect(json["amount"] as? Double == 1000.0)
  }

  @Test func zBAccountEncoding() throws {
    let account = ZBAccount(
      accountId: "acc-123",
      accountName: "Office Expenses",
      accountCode: "6000",
      accountType: "expense",
      description: "General office expenses",
      isActive: true
    )

    let data = try encoder.encode(account)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["account_id"] as? String == "acc-123")
    #expect(json["account_name"] as? String == "Office Expenses")
    #expect(json["account_code"] as? String == "6000")
    #expect(json["account_type"] as? String == "expense")
    #expect(json["is_active"] as? Bool == true)
  }

  @Test func zBTaxExemptionEncoding() throws {
    let exemption = ZBTaxExemption(
      taxExemptionId: "exempt-123",
      taxExemptionCode: "EXEMPT-001",
      description: "Non-profit exemption",
      type: "customer"
    )

    let data = try encoder.encode(exemption)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["tax_exemption_id"] as? String == "exempt-123")
    #expect(json["tax_exemption_code"] as? String == "EXEMPT-001")
    #expect(json["description"] as? String == "Non-profit exemption")
    #expect(json["type"] as? String == "customer")
  }
}
