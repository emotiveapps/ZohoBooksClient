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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["item_id"] as? String, "item-123")
    XCTAssertEqual(json["name"] as? String, "Test Item")
    XCTAssertEqual(json["rate"] as? Double, 99.99)
    XCTAssertEqual(json["sku"] as? String, "SKU-001")
    XCTAssertEqual(json["tax_id"] as? String, "tax-456")
    XCTAssertEqual(json["product_type"] as? String, "goods")
  }

  func testZBItemDecoding() throws {
    let json = Data("""
    {
        "item_id": "item-789",
        "name": "Decoded Item",
        "rate": 150.0,
        "tax_percentage": 10.5,
        "is_returnable": true,
        "status": "active"
    }
    """.utf8)

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["tax_id"] as? String, "tax-123")
    XCTAssertEqual(json["tax_name"] as? String, "GST")
    XCTAssertEqual(json["tax_percentage"] as? Double, 18.0)
    XCTAssertEqual(json["is_value_added"] as? Bool, true)
    XCTAssertEqual(json["is_default_tax"] as? Bool, false)
  }

  func testZBTaxDecoding() throws {
    let json = Data("""
    {
        "tax_id": "tax-456",
        "tax_name": "VAT",
        "tax_percentage": 20.0,
        "tax_type": "tax",
        "is_editable": true
    }
    """.utf8)

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["tax_name"] as? String, "Sales Tax")
    XCTAssertEqual(json["tax_percentage"] as? Double, 8.25)
    XCTAssertEqual(json["tax_type"] as? String, "tax")
  }

  func testZBTaxExemptionDecoding() throws {
    let json = Data("""
    {
        "tax_exemption_id": "exempt-001",
        "tax_exemption_code": "EXEMPT-SERVICE",
        "description": "Service tax exemption",
        "type": "customer"
    }
    """.utf8)

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

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
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])

    XCTAssertEqual(json["name"] as? String, "Service")
    XCTAssertEqual(json["rate"] as? Double, 200.0)
    XCTAssertEqual(json["quantity"] as? Double, 5.0)
    XCTAssertEqual(json["tax_id"] as? String, "tax-001")
  }
}
