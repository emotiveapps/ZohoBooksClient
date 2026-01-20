import XCTest
@testable import ZohoBooksClient

final class AdditionalModelTests: XCTestCase {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  // MARK: - ZBExpense Tests

  func testZBExpenseCreateRequestEncoding() throws {
    let request = ZBExpenseCreateRequest(
      accountId: "acc-123",
      vendorId: "vendor-001",
      date: "2024-01-20",
      amount: 500.0,
      currencyCode: "USD",
      description: "Office rent"
    )

    let data = try encoder.encode(request)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["account_id"] as? String, "acc-123")
    XCTAssertEqual(json["date"] as? String, "2024-01-20")
    XCTAssertEqual(json["amount"] as? Double, 500.0)
    XCTAssertEqual(json["description"] as? String, "Office rent")
    XCTAssertEqual(json["vendor_id"] as? String, "vendor-001")
    XCTAssertEqual(json["currency_code"] as? String, "USD")
  }

  // MARK: - ZBPayment Tests

  func testZBPaymentCreateRequestEncoding() throws {
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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["customer_id"] as? String, "cust-123")
    XCTAssertEqual(json["payment_mode"] as? String, "bank_transfer")
    XCTAssertEqual(json["amount"] as? Double, 1000.0)
    XCTAssertEqual(json["account_id"] as? String, "acc-bank")

    if let invoices = json["invoices"] as? [[String: Any]] {
      XCTAssertEqual(invoices.count, 1)
      XCTAssertEqual(invoices[0]["invoice_id"] as? String, "inv-001")
      XCTAssertEqual(invoices[0]["amount_applied"] as? Double, 1000.0)
    } else {
      XCTFail("invoices should be present")
    }
  }

  func testZBPaymentInvoiceEncoding() throws {
    let paymentInvoice = ZBPaymentInvoice(
      invoiceId: "inv-999",
      amountApplied: 250.50
    )

    let data = try encoder.encode(paymentInvoice)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["invoice_id"] as? String, "inv-999")
    XCTAssertEqual(json["amount_applied"] as? Double, 250.50)
  }

  // MARK: - ZBAccount Tests

  func testZBAccountTypeAllCases() {
    XCTAssertEqual(ZBAccountType.expense.rawValue, "expense")
    XCTAssertEqual(ZBAccountType.income.rawValue, "income")
    XCTAssertEqual(ZBAccountType.otherAsset.rawValue, "other_asset")
    XCTAssertEqual(ZBAccountType.otherCurrentAsset.rawValue, "other_current_asset")
    XCTAssertEqual(ZBAccountType.otherCurrentLiability.rawValue, "other_current_liability")
    XCTAssertEqual(ZBAccountType.longTermLiability.rawValue, "long_term_liability")
    XCTAssertEqual(ZBAccountType.equity.rawValue, "equity")
    XCTAssertEqual(ZBAccountType.bank.rawValue, "bank")
    XCTAssertEqual(ZBAccountType.creditCard.rawValue, "credit_card")
    XCTAssertEqual(ZBAccountType.cash.rawValue, "cash")
    XCTAssertEqual(ZBAccountType.fixedAsset.rawValue, "fixed_asset")
  }

  func testZBAccountCreateRequestEncoding() throws {
    let request = ZBAccountCreateRequest(
      accountName: "Office Supplies",
      accountType: "expense",
      description: "Expenses for office supplies"
    )

    let data = try encoder.encode(request)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["account_name"] as? String, "Office Supplies")
    XCTAssertEqual(json["account_type"] as? String, "expense")
    XCTAssertEqual(json["description"] as? String, "Expenses for office supplies")
  }

  func testZBAccountUpdateRequestEncoding() throws {
    let request = ZBAccountUpdateRequest(
      accountName: "Updated Account",
      parentAccountId: "parent-123"
    )

    let data = try encoder.encode(request)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["account_name"] as? String, "Updated Account")
    XCTAssertEqual(json["parent_account_id"] as? String, "parent-123")
  }

  // MARK: - Status and Mode Raw Values

  func testZBInvoiceStatusRawValues() {
    XCTAssertEqual(ZBInvoiceStatus.draft.rawValue, "draft")
    XCTAssertEqual(ZBInvoiceStatus.sent.rawValue, "sent")
    XCTAssertEqual(ZBInvoiceStatus.viewed.rawValue, "viewed")
    XCTAssertEqual(ZBInvoiceStatus.overdue.rawValue, "overdue")
    XCTAssertEqual(ZBInvoiceStatus.paid.rawValue, "paid")
    XCTAssertEqual(ZBInvoiceStatus.partiallyPaid.rawValue, "partially_paid")
    XCTAssertEqual(ZBInvoiceStatus.void.rawValue, "void")
  }

  func testZBPaymentModeRawValues() {
    XCTAssertEqual(ZBPaymentMode.cash.rawValue, "Cash")
    XCTAssertEqual(ZBPaymentMode.check.rawValue, "Check")
    XCTAssertEqual(ZBPaymentMode.creditCard.rawValue, "Credit Card")
    XCTAssertEqual(ZBPaymentMode.bankTransfer.rawValue, "Bank Transfer")
    XCTAssertEqual(ZBPaymentMode.paypal.rawValue, "PayPal")
    XCTAssertEqual(ZBPaymentMode.stripe.rawValue, "Stripe")
    XCTAssertEqual(ZBPaymentMode.square.rawValue, "Square")
  }

  // MARK: - Contact Person Tests

  func testZBContactPersonEncoding() throws {
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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["contact_person_id"] as? String, "person-123")
    XCTAssertEqual(json["salutation"] as? String, "Mr.")
    XCTAssertEqual(json["first_name"] as? String, "John")
    XCTAssertEqual(json["last_name"] as? String, "Doe")
    XCTAssertEqual(json["email"] as? String, "john@example.com")
    XCTAssertEqual(json["is_primary_contact"] as? Bool, true)
  }

  func testZBContactPersonDecoding() throws {
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

    XCTAssertEqual(person.contactPersonId, "person-456")
    XCTAssertEqual(person.firstName, "Jane")
    XCTAssertEqual(person.lastName, "Smith")
    XCTAssertEqual(person.email, "jane@example.com")
    XCTAssertEqual(person.isPrimaryContact, false)
  }

  func testZBPageContextDecoding() throws {
    let json = Data("""
    {
        "page": 1,
        "per_page": 25,
        "has_more_page": true,
        "total": 100
    }
    """.utf8)

    let context = try decoder.decode(ZBPageContext.self, from: json)

    XCTAssertEqual(context.page, 1)
    XCTAssertEqual(context.perPage, 25)
    XCTAssertEqual(context.hasMorePage, true)
    XCTAssertEqual(context.total, 100)
  }

  func testZBTagEncoding() throws {
    let tag = ZBTag(tagId: "tag-123", tagOptionId: "option-456")

    let data = try encoder.encode(tag)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["tag_id"] as? String, "tag-123")
    XCTAssertEqual(json["tag_option_id"] as? String, "option-456")
  }
}
