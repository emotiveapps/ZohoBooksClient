import Foundation

// MARK: - Response Types

struct ZBExpenseResponse: Codable, Sendable {
    let code: Int
    let message: String
    let expense: ZBExpense?
}

struct ZBExpenseListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let expenses: [ZBExpense]?
    let pageContext: ZBPageContext?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case expenses
        case pageContext = "page_context"
    }
}

// MARK: - Expense

/// An expense in Zoho Books
public struct ZBExpense: Codable, Sendable {
    public var expenseId: String?
    public var accountId: String?
    public var accountName: String?
    public var paidThroughAccountId: String?
    public var paidThroughAccountName: String?
    public var vendorId: String?
    public var vendorName: String?
    public var date: String?
    public var amount: Double?
    public var taxId: String?
    public var taxName: String?
    public var taxPercentage: Double?
    public var taxAmount: Double?
    public var subTotal: Double?
    public var total: Double?
    public var isBillable: Bool?
    public var customerId: String?
    public var customerName: String?
    public var projectId: String?
    public var projectName: String?
    public var currencyId: String?
    public var currencyCode: String?
    public var referenceNumber: String?
    public var description: String?
    public var status: String?

    enum CodingKeys: String, CodingKey {
        case expenseId = "expense_id"
        case accountId = "account_id"
        case accountName = "account_name"
        case paidThroughAccountId = "paid_through_account_id"
        case paidThroughAccountName = "paid_through_account_name"
        case vendorId = "vendor_id"
        case vendorName = "vendor_name"
        case date
        case amount
        case taxId = "tax_id"
        case taxName = "tax_name"
        case taxPercentage = "tax_percentage"
        case taxAmount = "tax_amount"
        case subTotal = "sub_total"
        case total
        case isBillable = "is_billable"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case projectId = "project_id"
        case projectName = "project_name"
        case currencyId = "currency_id"
        case currencyCode = "currency_code"
        case referenceNumber = "reference_number"
        case description
        case status
    }

    public init(
        expenseId: String? = nil,
        accountId: String? = nil,
        accountName: String? = nil,
        paidThroughAccountId: String? = nil,
        paidThroughAccountName: String? = nil,
        vendorId: String? = nil,
        vendorName: String? = nil,
        date: String? = nil,
        amount: Double? = nil,
        taxId: String? = nil,
        taxName: String? = nil,
        taxPercentage: Double? = nil,
        taxAmount: Double? = nil,
        subTotal: Double? = nil,
        total: Double? = nil,
        isBillable: Bool? = nil,
        customerId: String? = nil,
        customerName: String? = nil,
        projectId: String? = nil,
        projectName: String? = nil,
        currencyId: String? = nil,
        currencyCode: String? = nil,
        referenceNumber: String? = nil,
        description: String? = nil,
        status: String? = nil
    ) {
        self.expenseId = expenseId
        self.accountId = accountId
        self.accountName = accountName
        self.paidThroughAccountId = paidThroughAccountId
        self.paidThroughAccountName = paidThroughAccountName
        self.vendorId = vendorId
        self.vendorName = vendorName
        self.date = date
        self.amount = amount
        self.taxId = taxId
        self.taxName = taxName
        self.taxPercentage = taxPercentage
        self.taxAmount = taxAmount
        self.subTotal = subTotal
        self.total = total
        self.isBillable = isBillable
        self.customerId = customerId
        self.customerName = customerName
        self.projectId = projectId
        self.projectName = projectName
        self.currencyId = currencyId
        self.currencyCode = currencyCode
        self.referenceNumber = referenceNumber
        self.description = description
        self.status = status
    }
}

// MARK: - Create Request

/// Request to create a new expense
public struct ZBExpenseCreateRequest: Codable, Sendable {
    public var accountId: String
    public var paidThroughAccountId: String?
    public var vendorId: String?
    public var date: String
    public var amount: Double
    public var taxId: String?
    public var isBillable: Bool?
    public var customerId: String?
    public var projectId: String?
    public var currencyCode: String?
    public var referenceNumber: String?
    public var description: String?
    public var tags: [ZBTag]?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case paidThroughAccountId = "paid_through_account_id"
        case vendorId = "vendor_id"
        case date
        case amount
        case taxId = "tax_id"
        case isBillable = "is_billable"
        case customerId = "customer_id"
        case projectId = "project_id"
        case currencyCode = "currency_code"
        case referenceNumber = "reference_number"
        case description
        case tags
    }

    public init(
        accountId: String,
        paidThroughAccountId: String? = nil,
        vendorId: String? = nil,
        date: String,
        amount: Double,
        taxId: String? = nil,
        isBillable: Bool? = nil,
        customerId: String? = nil,
        projectId: String? = nil,
        currencyCode: String? = nil,
        referenceNumber: String? = nil,
        description: String? = nil,
        tags: [ZBTag]? = nil
    ) {
        self.accountId = accountId
        self.paidThroughAccountId = paidThroughAccountId
        self.vendorId = vendorId
        self.date = date
        self.amount = amount
        self.taxId = taxId
        self.isBillable = isBillable
        self.customerId = customerId
        self.projectId = projectId
        self.currencyCode = currencyCode
        self.referenceNumber = referenceNumber
        self.description = description
        self.tags = tags
    }
}

// MARK: - Tag

/// A tag for categorizing expenses
public struct ZBTag: Codable, Sendable {
    public var tagId: String
    public var tagOptionId: String

    enum CodingKeys: String, CodingKey {
        case tagId = "tag_id"
        case tagOptionId = "tag_option_id"
    }

    public init(tagId: String, tagOptionId: String) {
        self.tagId = tagId
        self.tagOptionId = tagOptionId
    }
}
