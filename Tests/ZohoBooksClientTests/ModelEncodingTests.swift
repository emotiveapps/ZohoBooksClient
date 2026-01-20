import XCTest
@testable import ZohoBooksClient

final class ModelEncodingTests: XCTestCase {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  // MARK: - ZBItem Tests

  func testZBItemEncoding() throws {
    let item = ZBItem(
      itemId: "item-123",
      name: "Test Item",
      description: "A test item",
      rate: 99.99,
      unit: "pcs",
      sku: "SKU-001",
      taxId: "tax-456",
      productType: "goods",
      status: "active"
    )

    let data = try encoder.encode(item)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["item_id"] as? String, "item-123")
    XCTAssertEqual(json["name"] as? String, "Test Item")
    XCTAssertEqual(json["rate"] as? Double, 99.99)
    XCTAssertEqual(json["sku"] as? String, "SKU-001")
    XCTAssertEqual(json["tax_id"] as? String, "tax-456")
    XCTAssertEqual(json["product_type"] as? String, "goods")
  }

  func testZBItemDecoding() throws {
    let json = """
    {
        "item_id": "item-789",
        "name": "Decoded Item",
        "rate": 150.0,
        "tax_percentage": 10.5,
        "is_returnable": true,
        "status": "active"
    }
    """.data(using: .utf8)!

    let item = try decoder.decode(ZBItem.self, from: json)

    XCTAssertEqual(item.itemId, "item-789")
    XCTAssertEqual(item.name, "Decoded Item")
    XCTAssertEqual(item.rate, 150.0)
    XCTAssertEqual(item.taxPercentage, 10.5)
    XCTAssertEqual(item.isReturnable, true)
    XCTAssertEqual(item.status, "active")
  }

  func testZBItemCreateRequestEncoding() throws {
    let request = ZBItemCreateRequest(
      name: "New Item",
      description: "Item description",
      rate: 50.0,
      unit: "hrs",
      sku: "SKU-NEW",
      taxId: "tax-001",
      productType: "service"
    )

    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["name"] as? String, "New Item")
    XCTAssertEqual(json["rate"] as? Double, 50.0)
    XCTAssertEqual(json["tax_id"] as? String, "tax-001")
    XCTAssertEqual(json["product_type"] as? String, "service")
  }

  func testZBProductTypeRawValues() {
    XCTAssertEqual(ZBProductType.goods.rawValue, "goods")
    XCTAssertEqual(ZBProductType.service.rawValue, "service")
  }

  // MARK: - ZBTax Tests

  func testZBTaxEncoding() throws {
    let tax = ZBTax(
      taxId: "tax-123",
      taxName: "GST",
      taxPercentage: 18.0,
      taxType: "tax",
      isValueAdded: true,
      isDefaultTax: false,
      status: "active"
    )

    let data = try encoder.encode(tax)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["tax_id"] as? String, "tax-123")
    XCTAssertEqual(json["tax_name"] as? String, "GST")
    XCTAssertEqual(json["tax_percentage"] as? Double, 18.0)
    XCTAssertEqual(json["is_value_added"] as? Bool, true)
    XCTAssertEqual(json["is_default_tax"] as? Bool, false)
  }

  func testZBTaxDecoding() throws {
    let json = """
    {
        "tax_id": "tax-456",
        "tax_name": "VAT",
        "tax_percentage": 20.0,
        "tax_type": "tax",
        "is_editable": true
    }
    """.data(using: .utf8)!

    let tax = try decoder.decode(ZBTax.self, from: json)

    XCTAssertEqual(tax.taxId, "tax-456")
    XCTAssertEqual(tax.taxName, "VAT")
    XCTAssertEqual(tax.taxPercentage, 20.0)
    XCTAssertEqual(tax.isEditable, true)
  }

  func testZBTaxCreateRequestEncoding() throws {
    let request = ZBTaxCreateRequest(
      taxName: "Sales Tax",
      taxPercentage: 8.25,
      taxType: "tax"
    )

    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["tax_name"] as? String, "Sales Tax")
    XCTAssertEqual(json["tax_percentage"] as? Double, 8.25)
    XCTAssertEqual(json["tax_type"] as? String, "tax")
  }

  func testZBTaxExemptionDecoding() throws {
    let json = """
    {
        "tax_exemption_id": "exempt-001",
        "tax_exemption_code": "EXEMPT-SERVICE",
        "description": "Service tax exemption",
        "type": "customer"
    }
    """.data(using: .utf8)!

    let exemption = try decoder.decode(ZBTaxExemption.self, from: json)

    XCTAssertEqual(exemption.taxExemptionId, "exempt-001")
    XCTAssertEqual(exemption.taxExemptionCode, "EXEMPT-SERVICE")
    XCTAssertEqual(exemption.description, "Service tax exemption")
    XCTAssertEqual(exemption.type, "customer")
  }

  // MARK: - ZBContact Tests

  func testZBContactTypeRawValues() {
    XCTAssertEqual(ZBContactType.customer.rawValue, "customer")
    XCTAssertEqual(ZBContactType.vendor.rawValue, "vendor")
  }

  func testZBContactCreateRequestEncoding() throws {
    let request = ZBContactCreateRequest(
      contactName: "Acme Corp",
      companyName: "Acme Corporation",
      contactType: "customer",
      billingAddress: ZBAddress(
        address: "123 Main St",
        city: "New York",
        state: "NY",
        zip: "10001",
        country: "USA"
      ),
      currencyCode: "USD"
    )

    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["contact_name"] as? String, "Acme Corp")
    XCTAssertEqual(json["company_name"] as? String, "Acme Corporation")
    XCTAssertEqual(json["contact_type"] as? String, "customer")
    XCTAssertEqual(json["currency_code"] as? String, "USD")

    if let billingAddress = json["billing_address"] as? [String: Any] {
      XCTAssertEqual(billingAddress["city"] as? String, "New York")
      XCTAssertEqual(billingAddress["state"] as? String, "NY")
    } else {
      XCTFail("billing_address should be present")
    }
  }

  func testZBAddressEncoding() throws {
    let address = ZBAddress(
      address: "456 Oak Ave",
      city: "Los Angeles",
      state: "CA",
      zip: "90001",
      country: "USA"
    )

    let data = try encoder.encode(address)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["address"] as? String, "456 Oak Ave")
    XCTAssertEqual(json["city"] as? String, "Los Angeles")
    XCTAssertEqual(json["state"] as? String, "CA")
    XCTAssertEqual(json["zip"] as? String, "90001")
  }

  // MARK: - ZBInvoice Tests

  func testZBInvoiceCreateRequestEncoding() throws {
    let lineItem = ZBInvoiceLineItemRequest(
      name: "Consulting",
      description: "Development services",
      rate: 150.0,
      quantity: 10.0
    )

    let request = ZBInvoiceCreateRequest(
      customerId: "cust-123",
      invoiceNumber: "INV-001",
      date: "2024-01-15",
      dueDate: "2024-02-15",
      lineItems: [lineItem]
    )

    let data = try encoder.encode(request)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["customer_id"] as? String, "cust-123")
    XCTAssertEqual(json["invoice_number"] as? String, "INV-001")
    XCTAssertEqual(json["date"] as? String, "2024-01-15")
    XCTAssertEqual(json["due_date"] as? String, "2024-02-15")

    if let lineItems = json["line_items"] as? [[String: Any]] {
      XCTAssertEqual(lineItems.count, 1)
      XCTAssertEqual(lineItems[0]["name"] as? String, "Consulting")
      XCTAssertEqual(lineItems[0]["rate"] as? Double, 150.0)
    } else {
      XCTFail("line_items should be present")
    }
  }

  func testZBInvoiceLineItemRequestEncoding() throws {
    let lineItem = ZBInvoiceLineItemRequest(
      name: "Service",
      description: "Professional services",
      rate: 200.0,
      quantity: 5.0,
      taxId: "tax-001"
    )

    let data = try encoder.encode(lineItem)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["name"] as? String, "Service")
    XCTAssertEqual(json["rate"] as? Double, 200.0)
    XCTAssertEqual(json["quantity"] as? Double, 5.0)
    XCTAssertEqual(json["tax_id"] as? String, "tax-001")
  }

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["account_name"] as? String, "Updated Account")
    XCTAssertEqual(json["parent_account_id"] as? String, "parent-123")
  }

  // MARK: - Additional Model Tests

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["contact_person_id"] as? String, "person-123")
    XCTAssertEqual(json["salutation"] as? String, "Mr.")
    XCTAssertEqual(json["first_name"] as? String, "John")
    XCTAssertEqual(json["last_name"] as? String, "Doe")
    XCTAssertEqual(json["email"] as? String, "john@example.com")
    XCTAssertEqual(json["is_primary_contact"] as? Bool, true)
  }

  func testZBContactPersonDecoding() throws {
    let json = """
    {
        "contact_person_id": "person-456",
        "first_name": "Jane",
        "last_name": "Smith",
        "email": "jane@example.com",
        "is_primary_contact": false
    }
    """.data(using: .utf8)!

    let person = try decoder.decode(ZBContactPerson.self, from: json)

    XCTAssertEqual(person.contactPersonId, "person-456")
    XCTAssertEqual(person.firstName, "Jane")
    XCTAssertEqual(person.lastName, "Smith")
    XCTAssertEqual(person.email, "jane@example.com")
    XCTAssertEqual(person.isPrimaryContact, false)
  }

  func testZBPageContextDecoding() throws {
    let json = """
    {
        "page": 1,
        "per_page": 25,
        "has_more_page": true,
        "total": 100
    }
    """.data(using: .utf8)!

    let context = try decoder.decode(ZBPageContext.self, from: json)

    XCTAssertEqual(context.page, 1)
    XCTAssertEqual(context.perPage, 25)
    XCTAssertEqual(context.hasMorePage, true)
    XCTAssertEqual(context.total, 100)
  }

  func testZBTagEncoding() throws {
    let tag = ZBTag(tagId: "tag-123", tagOptionId: "option-456")

    let data = try encoder.encode(tag)
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["tag_id"] as? String, "tag-123")
    XCTAssertEqual(json["tag_option_id"] as? String, "option-456")
  }

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

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
    let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

    XCTAssertEqual(json["tax_exemption_id"] as? String, "exempt-123")
    XCTAssertEqual(json["tax_exemption_code"] as? String, "EXEMPT-001")
    XCTAssertEqual(json["description"] as? String, "Non-profit exemption")
    XCTAssertEqual(json["type"] as? String, "customer")
  }
}
