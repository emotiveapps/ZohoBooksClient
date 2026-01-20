import Foundation

// MARK: - Response Types

struct ZBInvoiceResponse: Codable, Sendable {
    let code: Int
    let message: String
    let invoice: ZBInvoice?
}

struct ZBInvoiceListResponse: Codable, Sendable {
    let code: Int
    let message: String
    let invoices: [ZBInvoice]?
}

// MARK: - Invoice

/// An invoice in Zoho Books
public struct ZBInvoice: Codable, Sendable {
    public var invoiceId: String?
    public var invoiceNumber: String?
    public var customerId: String?
    public var customerName: String?
    public var status: String?
    public var date: String?
    public var dueDate: String?
    public var currencyId: String?
    public var currencyCode: String?
    public var total: Double?
    public var balance: Double?
    public var lineItems: [ZBInvoiceLineItem]?
    public var notes: String?
    public var terms: String?
    public var paymentTerms: Int?
    public var paymentTermsLabel: String?
    public var isInclusiveTax: Bool?
    public var referenceNumber: String?

    enum CodingKeys: String, CodingKey {
        case invoiceId = "invoice_id"
        case invoiceNumber = "invoice_number"
        case customerId = "customer_id"
        case customerName = "customer_name"
        case status
        case date
        case dueDate = "due_date"
        case currencyId = "currency_id"
        case currencyCode = "currency_code"
        case total
        case balance
        case lineItems = "line_items"
        case notes
        case terms
        case paymentTerms = "payment_terms"
        case paymentTermsLabel = "payment_terms_label"
        case isInclusiveTax = "is_inclusive_tax"
        case referenceNumber = "reference_number"
    }

    public init(
        invoiceId: String? = nil,
        invoiceNumber: String? = nil,
        customerId: String? = nil,
        customerName: String? = nil,
        status: String? = nil,
        date: String? = nil,
        dueDate: String? = nil,
        currencyId: String? = nil,
        currencyCode: String? = nil,
        total: Double? = nil,
        balance: Double? = nil,
        lineItems: [ZBInvoiceLineItem]? = nil,
        notes: String? = nil,
        terms: String? = nil,
        paymentTerms: Int? = nil,
        paymentTermsLabel: String? = nil,
        isInclusiveTax: Bool? = nil,
        referenceNumber: String? = nil
    ) {
        self.invoiceId = invoiceId
        self.invoiceNumber = invoiceNumber
        self.customerId = customerId
        self.customerName = customerName
        self.status = status
        self.date = date
        self.dueDate = dueDate
        self.currencyId = currencyId
        self.currencyCode = currencyCode
        self.total = total
        self.balance = balance
        self.lineItems = lineItems
        self.notes = notes
        self.terms = terms
        self.paymentTerms = paymentTerms
        self.paymentTermsLabel = paymentTermsLabel
        self.isInclusiveTax = isInclusiveTax
        self.referenceNumber = referenceNumber
    }
}

// MARK: - Line Item

/// A line item on an invoice
public struct ZBInvoiceLineItem: Codable, Sendable {
    public var lineItemId: String?
    public var itemId: String?
    public var name: String?
    public var description: String?
    public var rate: Double?
    public var quantity: Double?
    public var unit: String?
    public var taxId: String?
    public var taxName: String?
    public var taxPercentage: Double?
    public var itemTotal: Double?

    enum CodingKeys: String, CodingKey {
        case lineItemId = "line_item_id"
        case itemId = "item_id"
        case name
        case description
        case rate
        case quantity
        case unit
        case taxId = "tax_id"
        case taxName = "tax_name"
        case taxPercentage = "tax_percentage"
        case itemTotal = "item_total"
    }

    public init(
        lineItemId: String? = nil,
        itemId: String? = nil,
        name: String? = nil,
        description: String? = nil,
        rate: Double? = nil,
        quantity: Double? = nil,
        unit: String? = nil,
        taxId: String? = nil,
        taxName: String? = nil,
        taxPercentage: Double? = nil,
        itemTotal: Double? = nil
    ) {
        self.lineItemId = lineItemId
        self.itemId = itemId
        self.name = name
        self.description = description
        self.rate = rate
        self.quantity = quantity
        self.unit = unit
        self.taxId = taxId
        self.taxName = taxName
        self.taxPercentage = taxPercentage
        self.itemTotal = itemTotal
    }
}

// MARK: - Create Request

/// Request to create a new invoice
public struct ZBInvoiceCreateRequest: Codable, Sendable {
    public var customerId: String
    public var invoiceNumber: String?
    public var referenceNumber: String?
    public var date: String?
    public var dueDate: String?
    public var currencyCode: String?
    public var lineItems: [ZBInvoiceLineItemRequest]
    public var notes: String?
    public var terms: String?
    public var paymentTerms: Int?
    public var paymentTermsLabel: String?
    public var isInclusiveTax: Bool?

    enum CodingKeys: String, CodingKey {
        case customerId = "customer_id"
        case invoiceNumber = "invoice_number"
        case referenceNumber = "reference_number"
        case date
        case dueDate = "due_date"
        case currencyCode = "currency_code"
        case lineItems = "line_items"
        case notes
        case terms
        case paymentTerms = "payment_terms"
        case paymentTermsLabel = "payment_terms_label"
        case isInclusiveTax = "is_inclusive_tax"
    }

    public init(
        customerId: String,
        invoiceNumber: String? = nil,
        referenceNumber: String? = nil,
        date: String? = nil,
        dueDate: String? = nil,
        currencyCode: String? = nil,
        lineItems: [ZBInvoiceLineItemRequest],
        notes: String? = nil,
        terms: String? = nil,
        paymentTerms: Int? = nil,
        paymentTermsLabel: String? = nil,
        isInclusiveTax: Bool? = nil
    ) {
        self.customerId = customerId
        self.invoiceNumber = invoiceNumber
        self.referenceNumber = referenceNumber
        self.date = date
        self.dueDate = dueDate
        self.currencyCode = currencyCode
        self.lineItems = lineItems
        self.notes = notes
        self.terms = terms
        self.paymentTerms = paymentTerms
        self.paymentTermsLabel = paymentTermsLabel
        self.isInclusiveTax = isInclusiveTax
    }
}

/// A line item request for creating invoices
public struct ZBInvoiceLineItemRequest: Codable, Sendable {
    public var name: String?
    public var description: String?
    public var rate: Double?
    public var quantity: Double?
    public var taxId: String?
    public var isTaxable: Bool?
    public var taxExemptionId: String?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case rate
        case quantity
        case taxId = "tax_id"
        case isTaxable = "is_taxable"
        case taxExemptionId = "tax_exemption_id"
    }

    public init(
        name: String? = nil,
        description: String? = nil,
        rate: Double? = nil,
        quantity: Double? = nil,
        taxId: String? = nil,
        isTaxable: Bool? = nil,
        taxExemptionId: String? = nil
    ) {
        self.name = name
        self.description = description
        self.rate = rate
        self.quantity = quantity
        self.taxId = taxId
        self.isTaxable = isTaxable
        self.taxExemptionId = taxExemptionId
    }
}

/// Invoice status constants
public enum ZBInvoiceStatus: String, Sendable {
    case draft = "draft"
    case sent = "sent"
    case viewed = "viewed"
    case overdue = "overdue"
    case paid = "paid"
    case partiallyPaid = "partially_paid"
    case void = "void"
}
