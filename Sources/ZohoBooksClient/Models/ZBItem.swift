import Foundation

// MARK: - Response Types

struct ZBItemResponse: Codable, Sendable {
  let code: Int
  let message: String
  let item: ZBItem?
}

struct ZBItemListResponse: Codable, Sendable {
  let code: Int
  let message: String
  let items: [ZBItem]?
}

// MARK: - Item

/// An item/product in Zoho Books
public struct ZBItem: Codable, Sendable {
  public var itemId: String?
  public var name: String
  public var description: String?
  public var rate: Double?
  public var unit: String?
  public var sku: String?
  public var taxId: String?
  public var taxName: String?
  public var taxPercentage: Double?
  public var taxType: String?
  public var productType: String?
  public var isReturnable: Bool?
  public var status: String?

  enum CodingKeys: String, CodingKey {
    case itemId = "item_id"
    case name
    case description
    case rate
    case unit
    case sku
    case taxId = "tax_id"
    case taxName = "tax_name"
    case taxPercentage = "tax_percentage"
    case taxType = "tax_type"
    case productType = "product_type"
    case isReturnable = "is_returnable"
    case status
  }

  public init(
    itemId: String? = nil,
    name: String,
    description: String? = nil,
    rate: Double? = nil,
    unit: String? = nil,
    sku: String? = nil,
    taxId: String? = nil,
    taxName: String? = nil,
    taxPercentage: Double? = nil,
    taxType: String? = nil,
    productType: String? = nil,
    isReturnable: Bool? = nil,
    status: String? = nil
  ) {
    self.itemId = itemId
    self.name = name
    self.description = description
    self.rate = rate
    self.unit = unit
    self.sku = sku
    self.taxId = taxId
    self.taxName = taxName
    self.taxPercentage = taxPercentage
    self.taxType = taxType
    self.productType = productType
    self.isReturnable = isReturnable
    self.status = status
  }
}

// MARK: - Create Request

/// Request to create a new item
public struct ZBItemCreateRequest: Codable, Sendable {
  public var name: String
  public var description: String?
  public var rate: Double?
  public var unit: String?
  public var sku: String?
  public var taxId: String?
  public var productType: String?

  enum CodingKeys: String, CodingKey {
    case name
    case description
    case rate
    case unit
    case sku
    case taxId = "tax_id"
    case productType = "product_type"
  }

  public init(
    name: String,
    description: String? = nil,
    rate: Double? = nil,
    unit: String? = nil,
    sku: String? = nil,
    taxId: String? = nil,
    productType: String? = nil
  ) {
    self.name = name
    self.description = description
    self.rate = rate
    self.unit = unit
    self.sku = sku
    self.taxId = taxId
    self.productType = productType
  }
}

/// Item product types
public enum ZBProductType: String, Sendable {
  case goods
  case service
}
