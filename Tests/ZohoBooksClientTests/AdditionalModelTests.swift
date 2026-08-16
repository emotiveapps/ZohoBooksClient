import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct AdditionalModelTests {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  // MARK: - ZBExpense Tests

  @Test func zBExpenseCreateRequestEncoding() throws {
    let request = ZBExpenseCreateRequest(
      accountId: "acc-123",
      vendorId: "vendor-001",
      date: "2024-01-20",
      amount: 500.0,
      currencyCode: "USD",
      description: "Office rent"
    )

    let data = try encoder.encode(request)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["account_id"] as? String == "acc-123")
    #expect(json["date"] as? String == "2024-01-20")
    #expect(json["amount"] as? Double == 500.0)
    #expect(json["description"] as? String == "Office rent")
    #expect(json["vendor_id"] as? String == "vendor-001")
    #expect(json["currency_code"] as? String == "USD")
  }

  // MARK: - ZBPayment Tests

  @Test func zBPaymentCreateRequestEncoding() throws {
    let paymentInvoice = ZBPaymentInvoice(
      invoiceId: "inv-001",
      amountApplied: 1000.0
    )

    let request = ZBPaymentCreateRequest(
      customerId: "cust-123",
      invoices: [paymentInvoice],
      paymentMode: "bank_transfer",
      amount: 1000.0,
      date: "2024-01-25",
      accountId: "acc-bank"
    )

    let data = try encoder.encode(request)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["customer_id"] as? String == "cust-123")
    #expect(json["payment_mode"] as? String == "bank_transfer")
    #expect(json["amount"] as? Double == 1000.0)
    #expect(json["account_id"] as? String == "acc-bank")

    if let invoices = json["invoices"] as? [[String: Any]] {
      #expect(invoices.count == 1)
      #expect(invoices[0]["invoice_id"] as? String == "inv-001")
      #expect(invoices[0]["amount_applied"] as? Double == 1000.0)
    } else {
      Issue.record("invoices should be present")
    }
  }

  @Test func zBPaymentInvoiceEncoding() throws {
    let paymentInvoice = ZBPaymentInvoice(
      invoiceId: "inv-999",
      amountApplied: 250.50
    )

    let data = try encoder.encode(paymentInvoice)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["invoice_id"] as? String == "inv-999")
    #expect(json["amount_applied"] as? Double == 250.50)
  }

  // MARK: - ZBAccount Tests

  @Test func zBAccountTypeAllCases() {
    #expect(ZBAccountType.expense.rawValue == "expense")
    #expect(ZBAccountType.income.rawValue == "income")
    #expect(ZBAccountType.otherAsset.rawValue == "other_asset")
    #expect(ZBAccountType.otherCurrentAsset.rawValue == "other_current_asset")
    #expect(ZBAccountType.otherCurrentLiability.rawValue == "other_current_liability")
    #expect(ZBAccountType.longTermLiability.rawValue == "long_term_liability")
    #expect(ZBAccountType.equity.rawValue == "equity")
    #expect(ZBAccountType.bank.rawValue == "bank")
    #expect(ZBAccountType.creditCard.rawValue == "credit_card")
    #expect(ZBAccountType.cash.rawValue == "cash")
    #expect(ZBAccountType.fixedAsset.rawValue == "fixed_asset")
  }

  @Test func zBAccountCreateRequestEncoding() throws {
    let request = ZBAccountCreateRequest(
      accountName: "Office Supplies",
      accountType: "expense",
      description: "Expenses for office supplies"
    )

    let data = try encoder.encode(request)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["account_name"] as? String == "Office Supplies")
    #expect(json["account_type"] as? String == "expense")
    #expect(json["description"] as? String == "Expenses for office supplies")
  }

  @Test func zBAccountUpdateRequestEncoding() throws {
    let request = ZBAccountUpdateRequest(
      accountName: "Updated Account",
      parentAccountId: "parent-123"
    )

    let data = try encoder.encode(request)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["account_name"] as? String == "Updated Account")
    #expect(json["parent_account_id"] as? String == "parent-123")
  }

  // MARK: - Status and Mode Raw Values

  @Test func zBInvoiceStatusRawValues() {
    #expect(ZBInvoiceStatus.draft.rawValue == "draft")
    #expect(ZBInvoiceStatus.sent.rawValue == "sent")
    #expect(ZBInvoiceStatus.viewed.rawValue == "viewed")
    #expect(ZBInvoiceStatus.overdue.rawValue == "overdue")
    #expect(ZBInvoiceStatus.paid.rawValue == "paid")
    #expect(ZBInvoiceStatus.partiallyPaid.rawValue == "partially_paid")
    #expect(ZBInvoiceStatus.void.rawValue == "void")
  }

  @Test func zBPaymentModeRawValues() {
    #expect(ZBPaymentMode.cash.rawValue == "Cash")
    #expect(ZBPaymentMode.check.rawValue == "Check")
    #expect(ZBPaymentMode.creditCard.rawValue == "Credit Card")
    #expect(ZBPaymentMode.bankTransfer.rawValue == "Bank Transfer")
    #expect(ZBPaymentMode.paypal.rawValue == "PayPal")
    #expect(ZBPaymentMode.stripe.rawValue == "Stripe")
    #expect(ZBPaymentMode.square.rawValue == "Square")
  }

  // MARK: - Contact Person Tests

  @Test func zBContactPersonEncoding() throws {
    let person = ZBContactPerson(
      contactPersonId: "person-123",
      salutation: "Mr.",
      firstName: "John",
      lastName: "Doe",
      email: "john@example.com",
      phone: "555-1234",
      mobile: "555-5678",
      isPrimaryContact: true
    )

    let data = try encoder.encode(person)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["contact_person_id"] as? String == "person-123")
    #expect(json["salutation"] as? String == "Mr.")
    #expect(json["first_name"] as? String == "John")
    #expect(json["last_name"] as? String == "Doe")
    #expect(json["email"] as? String == "john@example.com")
    #expect(json["is_primary_contact"] as? Bool == true)
  }

  @Test func zBContactPersonDecoding() throws {
    let json = Data("""
    {
        "contact_person_id": "person-456",
        "first_name": "Jane",
        "last_name": "Smith",
        "email": "jane@example.com",
        "is_primary_contact": false
    }
    """.utf8)

    let person = try decoder.decode(ZBContactPerson.self, from: json)

    #expect(person.contactPersonId == "person-456")
    #expect(person.firstName == "Jane")
    #expect(person.lastName == "Smith")
    #expect(person.email == "jane@example.com")
    #expect(person.isPrimaryContact == false)
  }

  @Test func zBPageContextDecoding() throws {
    let json = Data("""
    {
        "page": 1,
        "per_page": 25,
        "has_more_page": true,
        "total": 100
    }
    """.utf8)

    let context = try decoder.decode(ZBPageContext.self, from: json)

    #expect(context.page == 1)
    #expect(context.perPage == 25)
    #expect(context.hasMorePage == true)
    #expect(context.total == 100)
  }

  @Test func zBTagEncoding() throws {
    let tag = ZBTag(tagId: "tag-123", tagOptionId: "option-456")

    let data = try encoder.encode(tag)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["tag_id"] as? String == "tag-123")
    #expect(json["tag_option_id"] as? String == "option-456")
  }
}
