import Foundation

// MARK: - Response Types

struct ZBAccountResponse: Codable, Sendable {
    let code: Int
    let message: String
    let chartOfAccount: ZBAccount?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case chartOfAccount = "chart_of_account"
    }
}

struct ZBAccountListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let chartOfAccounts: [ZBAccount]?

    enum CodingKeys: String, CodingKey {
        case code
        case message
        case chartOfAccounts = "chartofaccounts"
    }
}

// MARK: - Account

/// An account in the chart of accounts
public struct ZBAccount: Codable, Sendable {
    public var accountId: String?
    public var accountName: String?
    public var accountCode: String?
    public var accountType: String?
    public var description: String?
    public var isActive: Bool?
    public var isUserCreated: Bool?
    public var isSystemAccount: Bool?
    public var parentAccountId: String?
    public var parentAccountName: String?
    public var depth: Int?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case accountName = "account_name"
        case accountCode = "account_code"
        case accountType = "account_type"
        case description
        case isActive = "is_active"
        case isUserCreated = "is_user_created"
        case isSystemAccount = "is_system_account"
        case parentAccountId = "parent_account_id"
        case parentAccountName = "parent_account_name"
        case depth
    }

    public init(
        accountId: String? = nil,
        accountName: String? = nil,
        accountCode: String? = nil,
        accountType: String? = nil,
        description: String? = nil,
        isActive: Bool? = nil,
        isUserCreated: Bool? = nil,
        isSystemAccount: Bool? = nil,
        parentAccountId: String? = nil,
        parentAccountName: String? = nil,
        depth: Int? = nil
    ) {
        self.accountId = accountId
        self.accountName = accountName
        self.accountCode = accountCode
        self.accountType = accountType
        self.description = description
        self.isActive = isActive
        self.isUserCreated = isUserCreated
        self.isSystemAccount = isSystemAccount
        self.parentAccountId = parentAccountId
        self.parentAccountName = parentAccountName
        self.depth = depth
    }
}

// MARK: - Create Request

/// Request to create a new account
public struct ZBAccountCreateRequest: Codable, Sendable {
    public var accountName: String
    public var accountType: String
    public var accountCode: String?
    public var description: String?
    public var parentAccountId: String?

    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case accountType = "account_type"
        case accountCode = "account_code"
        case description
        case parentAccountId = "parent_account_id"
    }

    public init(
        accountName: String,
        accountType: String,
        accountCode: String? = nil,
        description: String? = nil,
        parentAccountId: String? = nil
    ) {
        self.accountName = accountName
        self.accountType = accountType
        self.accountCode = accountCode
        self.description = description
        self.parentAccountId = parentAccountId
    }
}

// MARK: - Update Request

/// Request to update an existing account
public struct ZBAccountUpdateRequest: Codable, Sendable {
    public var accountName: String?
    public var parentAccountId: String?

    enum CodingKeys: String, CodingKey {
        case accountName = "account_name"
        case parentAccountId = "parent_account_id"
    }

    public init(accountName: String? = nil, parentAccountId: String? = nil) {
        self.accountName = accountName
        self.parentAccountId = parentAccountId
    }
}

// MARK: - Account Types

/// Zoho Books account types
public enum ZBAccountType: String, Sendable, Codable {
    case otherAsset = "other_asset"
    case otherCurrentAsset = "other_current_asset"
    case cash = "cash"
    case bank = "bank"
    case fixedAsset = "fixed_asset"
    case otherCurrentLiability = "other_current_liability"
    case creditCard = "credit_card"
    case longTermLiability = "long_term_liability"
    case otherLiability = "other_liability"
    case equity = "equity"
    case income = "income"
    case otherIncome = "other_income"
    case expense = "expense"
    case costOfGoodsSold = "cost_of_goods_sold"
    case otherExpense = "other_expense"
    case accountsReceivable = "accounts_receivable"
    case accountsPayable = "accounts_payable"
}
