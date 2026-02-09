import Foundation

// MARK: - Response Types

struct ZBBankAccountListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let bankaccounts: [ZBBankAccount]?
    let pageContext: ZBPageContext?

    enum CodingKeys: String, CodingKey {
        case code, message, bankaccounts
        case pageContext = "page_context"
    }
}

struct ZBBankTransactionListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let banktransactions: [ZBBankTransaction]?
    let pageContext: ZBPageContext?

    enum CodingKeys: String, CodingKey {
        case code, message, banktransactions
        case pageContext = "page_context"
    }
}

struct ZBCategorizeResponse: Codable, Sendable {
    let code: Int
    let message: String
}

// MARK: - Bank Account

/// A bank account in Zoho Books
public struct ZBBankAccount: Codable, Sendable {
    public let accountId: String
    public let accountName: String
    public let accountType: String
    public let accountNumber: String?
    public let balance: Double?
    public let bankName: String?
    public let isActive: Bool?
    public let currencyCode: String?
    public let description: String?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case accountName = "account_name"
        case accountType = "account_type"
        case accountNumber = "account_number"
        case balance
        case bankName = "bank_name"
        case isActive = "is_active"
        case currencyCode = "currency_code"
        case description
    }

    public init(
        accountId: String,
        accountName: String,
        accountType: String,
        accountNumber: String? = nil,
        balance: Double? = nil,
        bankName: String? = nil,
        isActive: Bool? = nil,
        currencyCode: String? = nil,
        description: String? = nil
    ) {
        self.accountId = accountId
        self.accountName = accountName
        self.accountType = accountType
        self.accountNumber = accountNumber
        self.balance = balance
        self.bankName = bankName
        self.isActive = isActive
        self.currencyCode = currencyCode
        self.description = description
    }
}

// MARK: - Bank Transaction

/// A bank transaction in Zoho Books
public struct ZBBankTransaction: Codable, Sendable {
    public let transactionId: String
    public let date: String
    public let amount: Double
    public let debitOrCredit: String
    public let description: String?
    public let referenceNumber: String?
    public let payee: String?
    public let status: String?
    public let accountId: String?
    public let accountName: String?
    public let statementId: String?
    public let importedTransactionId: String?
    public let bankCharges: Double?

    /// Whether this is a debit (expense/outflow)
    public var isDebit: Bool {
        debitOrCredit.lowercased() == "debit"
    }

    /// Display-formatted amount with currency symbol
    public var displayAmount: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        let value = isDebit ? -amount : amount
        return formatter.string(from: NSNumber(value: value)) ?? String(format: "$%.2f", value)
    }

    /// The display description (prefers payee over description)
    public var displayDescription: String {
        payee ?? description ?? "No description"
    }

    /// URL to view this transaction in Zoho Books
    public var zohoURL: String {
        "https://books.zoho.com/app#/bankaccounts/\(accountId ?? "")/transactions/\(transactionId)"
    }

    enum CodingKeys: String, CodingKey {
        case transactionId = "transaction_id"
        case date, amount
        case debitOrCredit = "debit_or_credit"
        case description
        case referenceNumber = "reference_number"
        case payee, status
        case accountId = "account_id"
        case accountName = "account_name"
        case statementId = "statement_id"
        case importedTransactionId = "imported_transaction_id"
        case bankCharges = "bank_charges"
    }

    public init(
        transactionId: String,
        date: String,
        amount: Double,
        debitOrCredit: String,
        description: String? = nil,
        referenceNumber: String? = nil,
        payee: String? = nil,
        status: String? = nil,
        accountId: String? = nil,
        accountName: String? = nil,
        statementId: String? = nil,
        importedTransactionId: String? = nil,
        bankCharges: Double? = nil
    ) {
        self.transactionId = transactionId
        self.date = date
        self.amount = amount
        self.debitOrCredit = debitOrCredit
        self.description = description
        self.referenceNumber = referenceNumber
        self.payee = payee
        self.status = status
        self.accountId = accountId
        self.accountName = accountName
        self.statementId = statementId
        self.importedTransactionId = importedTransactionId
        self.bankCharges = bankCharges
    }
}

// MARK: - Categorization Requests

/// Request to categorize a bank transaction as an expense
public struct ZBCategorizeExpenseRequest: Codable, Sendable {
    public let accountId: String
    public let vendorId: String?
    public let paidThroughAccountId: String?
    public let description: String?
    public let date: String?
    public let amount: Double?
    public let taxId: String?

    enum CodingKeys: String, CodingKey {
        case accountId = "account_id"
        case vendorId = "vendor_id"
        case paidThroughAccountId = "paid_through_account_id"
        case description, date, amount
        case taxId = "tax_id"
    }

    public init(
        accountId: String,
        vendorId: String? = nil,
        paidThroughAccountId: String? = nil,
        description: String? = nil,
        date: String? = nil,
        amount: Double? = nil,
        taxId: String? = nil
    ) {
        self.accountId = accountId
        self.vendorId = vendorId
        self.paidThroughAccountId = paidThroughAccountId
        self.description = description
        self.date = date
        self.amount = amount
        self.taxId = taxId
    }
}

/// Request to categorize a bank transaction as a transfer
public struct ZBCategorizeTransferRequest: Codable, Sendable {
    public let transactionType: String
    public let toAccountId: String?
    public let fromAccountId: String?
    public let amount: Double?
    public let referenceNumber: String?
    public let description: String?

    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_type"
        case toAccountId = "to_account_id"
        case fromAccountId = "from_account_id"
        case amount
        case referenceNumber = "reference_number"
        case description
    }

    public init(
        toAccountId: String? = nil,
        fromAccountId: String? = nil,
        amount: Double? = nil,
        referenceNumber: String? = nil,
        description: String? = nil
    ) {
        self.transactionType = "transfer_fund"
        self.toAccountId = toAccountId
        self.fromAccountId = fromAccountId
        self.amount = amount
        self.referenceNumber = referenceNumber
        self.description = description
    }
}

/// Request to categorize a bank transaction as owner contribution
public struct ZBCategorizeOwnerContributionRequest: Codable, Sendable {
    public let transactionType: String
    public let accountId: String
    public let description: String?
    public let date: String?

    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_type"
        case accountId = "account_id"
        case description, date
    }

    public init(
        accountId: String,
        description: String? = nil,
        date: String? = nil
    ) {
        self.transactionType = "owner_contribution"
        self.accountId = accountId
        self.description = description
        self.date = date
    }
}

/// Request to categorize a bank transaction as a sale
public struct ZBCategorizeSaleRequest: Codable, Sendable {
    public let transactionType: String
    public let accountId: String
    public let customerId: String?
    public let customerName: String?
    public let description: String?
    public let date: String?

    enum CodingKeys: String, CodingKey {
        case transactionType = "transaction_type"
        case accountId = "account_id"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case description, date
    }

    public init(
        accountId: String,
        customerId: String? = nil,
        customerName: String? = nil,
        description: String? = nil,
        date: String? = nil
    ) {
        self.transactionType = "sales_without_invoices"
        self.accountId = accountId
        self.customerId = customerId
        self.customerName = customerName
        self.description = description
        self.date = date
    }
}
