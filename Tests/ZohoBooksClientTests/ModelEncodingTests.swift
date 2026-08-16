import Foundation
import Testing
@testable import ZohoBooksClient

@Suite struct ModelEncodingTests {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  // MARK: - ZBItem Tests

  @Test func zBItemEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["item_id"] as? String == "item-123")
    #expect(json["name"] as? String == "Test Item")
    #expect(json["rate"] as? Double == 99.99)
    #expect(json["sku"] as? String == "SKU-001")
    #expect(json["tax_id"] as? String == "tax-456")
    #expect(json["product_type"] as? String == "goods")
  }

  @Test func zBItemDecoding() throws {
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

    #expect(item.itemId == "item-789")
    #expect(item.name == "Decoded Item")
    #expect(item.rate == 150.0)
    #expect(item.taxPercentage == 10.5)
    #expect(item.isReturnable == true)
    #expect(item.status == "active")
  }

  @Test func zBItemCreateRequestEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["name"] as? String == "New Item")
    #expect(json["rate"] as? Double == 50.0)
    #expect(json["tax_id"] as? String == "tax-001")
    #expect(json["product_type"] as? String == "service")
  }

  @Test func zBProductTypeRawValues() {
    #expect(ZBProductType.goods.rawValue == "goods")
    #expect(ZBProductType.service.rawValue == "service")
  }

  // MARK: - ZBTax Tests

  @Test func zBTaxEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["tax_id"] as? String == "tax-123")
    #expect(json["tax_name"] as? String == "GST")
    #expect(json["tax_percentage"] as? Double == 18.0)
    #expect(json["is_value_added"] as? Bool == true)
    #expect(json["is_default_tax"] as? Bool == false)
  }

  @Test func zBTaxDecoding() throws {
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

    #expect(tax.taxId == "tax-456")
    #expect(tax.taxName == "VAT")
    #expect(tax.taxPercentage == 20.0)
    #expect(tax.isEditable == true)
  }

  @Test func zBTaxCreateRequestEncoding() throws {
    let request = ZBTaxCreateRequest(
      taxName: "Sales Tax",
      taxPercentage: 8.25,
      taxType: "tax"
    )

    let data = try encoder.encode(request)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["tax_name"] as? String == "Sales Tax")
    #expect(json["tax_percentage"] as? Double == 8.25)
    #expect(json["tax_type"] as? String == "tax")
  }

  @Test func zBTaxExemptionDecoding() throws {
    let json = Data("""
    {
        "tax_exemption_id": "exempt-001",
        "tax_exemption_code": "EXEMPT-SERVICE",
        "description": "Service tax exemption",
        "type": "customer"
    }
    """.utf8)

    let exemption = try decoder.decode(ZBTaxExemption.self, from: json)

    #expect(exemption.taxExemptionId == "exempt-001")
    #expect(exemption.taxExemptionCode == "EXEMPT-SERVICE")
    #expect(exemption.description == "Service tax exemption")
    #expect(exemption.type == "customer")
  }

  // MARK: - ZBContact Tests

  @Test func zBContactTypeRawValues() {
    #expect(ZBContactType.customer.rawValue == "customer")
    #expect(ZBContactType.vendor.rawValue == "vendor")
  }

  @Test func zBContactCreateRequestEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["contact_name"] as? String == "Acme Corp")
    #expect(json["company_name"] as? String == "Acme Corporation")
    #expect(json["contact_type"] as? String == "customer")
    #expect(json["currency_code"] as? String == "USD")

    if let billingAddress = json["billing_address"] as? [String: Any] {
      #expect(billingAddress["city"] as? String == "New York")
      #expect(billingAddress["state"] as? String == "NY")
    } else {
      Issue.record("billing_address should be present")
    }
  }

  @Test func zBAddressEncoding() throws {
    let address = ZBAddress(
      address: "456 Oak Ave",
      city: "Los Angeles",
      state: "CA",
      zip: "90001",
      country: "USA"
    )

    let data = try encoder.encode(address)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["address"] as? String == "456 Oak Ave")
    #expect(json["city"] as? String == "Los Angeles")
    #expect(json["state"] as? String == "CA")
    #expect(json["zip"] as? String == "90001")
  }

  // MARK: - ZBInvoice Tests

  @Test func zBInvoiceCreateRequestEncoding() throws {
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
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["customer_id"] as? String == "cust-123")
    #expect(json["invoice_number"] as? String == "INV-001")
    #expect(json["date"] as? String == "2024-01-15")
    #expect(json["due_date"] as? String == "2024-02-15")

    if let lineItems = json["line_items"] as? [[String: Any]] {
      #expect(lineItems.count == 1)
      #expect(lineItems[0]["name"] as? String == "Consulting")
      #expect(lineItems[0]["rate"] as? Double == 150.0)
    } else {
      Issue.record("line_items should be present")
    }
  }

  @Test func zBInvoiceLineItemRequestEncoding() throws {
    let lineItem = ZBInvoiceLineItemRequest(
      name: "Service",
      description: "Professional services",
      rate: 200.0,
      quantity: 5.0,
      taxId: "tax-001"
    )

    let data = try encoder.encode(lineItem)
    let json = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

    #expect(json["name"] as? String == "Service")
    #expect(json["rate"] as? Double == 200.0)
    #expect(json["quantity"] as? Double == 5.0)
    #expect(json["tax_id"] as? String == "tax-001")
  }
}
