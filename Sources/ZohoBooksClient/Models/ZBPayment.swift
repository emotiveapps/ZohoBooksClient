import Foundation

// MARK: - Response Types

struct ZBPaymentResponse: Codable, Sendable {
  let code: Int
  let message: String
  let payment: ZBPayment?
}

struct ZBPaymentListResponse: Codable, Sendable {
  let code: Int
  let message: String
  let customerpayments: [ZBPayment]?
}

// MARK: - Payment

/// A customer payment in Zoho Books
public struct ZBPayment: Codable, Sendable {
  public var paymentId: String?
  public var customerId: String?
  public var customerName: String?
  public var invoices: [ZBPaymentInvoice]?
  public var paymentMode: String?
  public var amount: Double?
  public var bankCharges: Double?
  public var date: String?
  public var referenceNumber: String?
  public var description: String?
  public var accountId: String?
  public var accountName: String?

  enum CodingKeys: String, CodingKey {
    case paymentId = "payment_id"
    case customerId = "customer_id"
    case customerName = "customer_name"
    case invoices
    case paymentMode = "payment_mode"
    case amount
    case bankCharges = "bank_charges"
    case date
    case referenceNumber = "reference_number"
    case description
    case accountId = "account_id"
    case accountName = "account_name"
  }

  public init(
    paymentId: String? = nil,
    customerId: String? = nil,
    customerName: String? = nil,
    invoices: [ZBPaymentInvoice]? = nil,
    paymentMode: String? = nil,
    amount: Double? = nil,
    bankCharges: Double? = nil,
    date: String? = nil,
    referenceNumber: String? = nil,
    description: String? = nil,
    accountId: String? = nil,
    accountName: String? = nil
  ) {
    self.paymentId = paymentId
    self.customerId = customerId
    self.customerName = customerName
    self.invoices = invoices
    self.paymentMode = paymentMode
    self.amount = amount
    self.bankCharges = bankCharges
    self.date = date
    self.referenceNumber = referenceNumber
    self.description = description
    self.accountId = accountId
    self.accountName = accountName
  }
}

// MARK: - Payment Invoice

/// An invoice associated with a payment
public struct ZBPaymentInvoice: Codable, Sendable {
  public var invoiceId: String
  public var amountApplied: Double

  enum CodingKeys: String, CodingKey {
    case invoiceId = "invoice_id"
    case amountApplied = "amount_applied"
  }

  public init(invoiceId: String, amountApplied: Double) {
    self.invoiceId = invoiceId
    self.amountApplied = amountApplied
  }
}

// MARK: - Create Request

/// Request to create a new payment
public struct ZBPaymentCreateRequest: Codable, Sendable {
  public var customerId: String
  public var invoices: [ZBPaymentInvoice]?
  public var paymentMode: String?
  public var amount: Double
  public var date: String
  public var referenceNumber: String?
  public var description: String?
  public var accountId: String?

  enum CodingKeys: String, CodingKey {
    case customerId = "customer_id"
    case invoices
    case paymentMode = "payment_mode"
    case amount
    case date
    case referenceNumber = "reference_number"
    case description
    case accountId = "account_id"
  }

  public init(
    customerId: String,
    invoices: [ZBPaymentInvoice]? = nil,
    paymentMode: String? = nil,
    amount: Double,
    date: String,
    referenceNumber: String? = nil,
    description: String? = nil,
    accountId: String? = nil
  ) {
    self.customerId = customerId
    self.invoices = invoices
    self.paymentMode = paymentMode
    self.amount = amount
    self.date = date
    self.referenceNumber = referenceNumber
    self.description = description
    self.accountId = accountId
  }
}

/// Common payment modes
public enum ZBPaymentMode: String, Sendable {
  case cash = "Cash"
  case check = "Check"
  case creditCard = "Credit Card"
  case bankTransfer = "Bank Transfer"
  case paypal = "PayPal"
  case stripe = "Stripe"
  case square = "Square"
}
