import Foundation

// MARK: - Response Types

struct ZBTaxResponse: Codable, Sendable {
    let code: Int
    let message: String
    let tax: ZBTax?
}

struct ZBTaxListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let taxes: [ZBTax]?
}

struct ZBTaxExemptionListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let taxExemptions: [ZBTaxExemption]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case taxExemptions = "tax_exemptions"
    }
}

// MARK: - Tax

/// A tax in Zoho Books
public struct ZBTax: Codable, Sendable {
    public var taxId: String?
    public var taxName: String?
    public var taxPercentage: Double?
    public var taxType: String?
    public var taxSpecificType: String?
    public var isValueAdded: Bool?
    public var isDefaultTax: Bool?
    public var isEditable: Bool?
    public var status: String?

    enum CodingKeys: String, CodingKey {
        case taxId = "tax_id"
        case taxName = "tax_name"
        case taxPercentage = "tax_percentage"
        case taxType = "tax_type"
        case taxSpecificType = "tax_specific_type"
        case isValueAdded = "is_value_added"
        case isDefaultTax = "is_default_tax"
        case isEditable = "is_editable"
        case status
    }

    public init(
        taxId: String? = nil,
        taxName: String? = nil,
        taxPercentage: Double? = nil,
        taxType: String? = nil,
        taxSpecificType: String? = nil,
        isValueAdded: Bool? = nil,
        isDefaultTax: Bool? = nil,
        isEditable: Bool? = nil,
        status: String? = nil
    ) {
        self.taxId = taxId
        self.taxName = taxName
        self.taxPercentage = taxPercentage
        self.taxType = taxType
        self.taxSpecificType = taxSpecificType
        self.isValueAdded = isValueAdded
        self.isDefaultTax = isDefaultTax
        self.isEditable = isEditable
        self.status = status
    }
}

// MARK: - Create Request

/// Request to create a new tax
public struct ZBTaxCreateRequest: Codable, Sendable {
    public var taxName: String
    public var taxPercentage: Double
    public var taxType: String?

    enum CodingKeys: String, CodingKey {
        case taxName = "tax_name"
        case taxPercentage = "tax_percentage"
        case taxType = "tax_type"
    }

    public init(taxName: String, taxPercentage: Double, taxType: String? = nil) {
        self.taxName = taxName
        self.taxPercentage = taxPercentage
        self.taxType = taxType
    }
}

// MARK: - Tax Exemption

/// A tax exemption in Zoho Books
public struct ZBTaxExemption: Codable, Sendable {
    public var taxExemptionId: String?
    public var taxExemptionCode: String?
    public var description: String?
    public var type: String?

    enum CodingKeys: String, CodingKey {
        case taxExemptionId = "tax_exemption_id"
        case taxExemptionCode = "tax_exemption_code"
        case description
        case type
    }

    public init(
        taxExemptionId: String? = nil,
        taxExemptionCode: String? = nil,
        description: String? = nil,
        type: String? = nil
    ) {
        self.taxExemptionId = taxExemptionId
        self.taxExemptionCode = taxExemptionCode
        self.description = description
        self.type = type
    }
}
