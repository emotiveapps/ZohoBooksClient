import Foundation

// MARK: - Response Types

struct ZBContactResponse: Codable, Sendable {
  let code: Int
  let message: String
  let contact: ZBContact?
}

struct ZBContactListResponse: Codable, Sendable {
  let code: Int
  let message: String
  let contacts: [ZBContact]?
  let pageContext: ZBPageContext?

  enum CodingKeys: String, CodingKey {
    case code
    case message
    case contacts
    case pageContext = "page_context"
  }
}

// MARK: - Page Context

/// Pagination context for list responses
public struct ZBPageContext: Codable, Sendable {
  public let page: Int?
  public let perPage: Int?
  public let hasMorePage: Bool?
  public let total: Int?

  enum CodingKeys: String, CodingKey {
    case page
    case perPage = "per_page"
    case hasMorePage = "has_more_page"
    case total
  }
}

// MARK: - Contact

/// A contact in Zoho Books (customer or vendor)
public struct ZBContact: Codable, Sendable {
  public var contactId: String?
  public var contactName: String?
  public var companyName: String?
  public var contactType: String?
  public var customerSubType: String?
  public var billingAddress: ZBAddress?
  public var shippingAddress: ZBAddress?
  public var contactPersons: [ZBContactPerson]?
  public var currencyId: String?
  public var currencyCode: String?
  public var paymentTerms: Int?
  public var paymentTermsLabel: String?
  public var notes: String?
  public var website: String?
  public var taxId: String?
  public var email: String?
  public var phone: String?
  public var mobile: String?
  public var fax: String?

  enum CodingKeys: String, CodingKey {
    case contactId = "contact_id"
    case contactName = "contact_name"
    case companyName = "company_name"
    case contactType = "contact_type"
    case customerSubType = "customer_sub_type"
    case billingAddress = "billing_address"
    case shippingAddress = "shipping_address"
    case contactPersons = "contact_persons"
    case currencyId = "currency_id"
    case currencyCode = "currency_code"
    case paymentTerms = "payment_terms"
    case paymentTermsLabel = "payment_terms_label"
    case notes
    case website
    case taxId = "tax_id"
    case email
    case phone
    case mobile
    case fax
  }

  public init(
    contactId: String? = nil,
    contactName: String? = nil,
    companyName: String? = nil,
    contactType: String? = nil,
    customerSubType: String? = nil,
    billingAddress: ZBAddress? = nil,
    shippingAddress: ZBAddress? = nil,
    contactPersons: [ZBContactPerson]? = nil,
    currencyId: String? = nil,
    currencyCode: String? = nil,
    paymentTerms: Int? = nil,
    paymentTermsLabel: String? = nil,
    notes: String? = nil,
    website: String? = nil,
    taxId: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    mobile: String? = nil,
    fax: String? = nil
  ) {
    self.contactId = contactId
    self.contactName = contactName
    self.companyName = companyName
    self.contactType = contactType
    self.customerSubType = customerSubType
    self.billingAddress = billingAddress
    self.shippingAddress = shippingAddress
    self.contactPersons = contactPersons
    self.currencyId = currencyId
    self.currencyCode = currencyCode
    self.paymentTerms = paymentTerms
    self.paymentTermsLabel = paymentTermsLabel
    self.notes = notes
    self.website = website
    self.taxId = taxId
    self.email = email
    self.phone = phone
    self.mobile = mobile
    self.fax = fax
  }
}

// MARK: - Address

/// An address in Zoho Books
public struct ZBAddress: Codable, Sendable {
  public var attention: String?
  public var address: String?
  public var street2: String?
  public var city: String?
  public var state: String?
  public var zip: String?
  public var country: String?
  public var phone: String?
  public var fax: String?

  public init(
    attention: String? = nil,
    address: String? = nil,
    street2: String? = nil,
    city: String? = nil,
    state: String? = nil,
    zip: String? = nil,
    country: String? = nil,
    phone: String? = nil,
    fax: String? = nil
  ) {
    self.attention = attention
    self.address = address
    self.street2 = street2
    self.city = city
    self.state = state
    self.zip = zip
    self.country = country
    self.phone = phone
    self.fax = fax
  }
}

// MARK: - Contact Person

/// A contact person associated with a contact
public struct ZBContactPerson: Codable, Sendable {
  public var contactPersonId: String?
  public var salutation: String?
  public var firstName: String?
  public var lastName: String?
  public var email: String?
  public var phone: String?
  public var mobile: String?
  public var isPrimaryContact: Bool?

  enum CodingKeys: String, CodingKey {
    case contactPersonId = "contact_person_id"
    case salutation
    case firstName = "first_name"
    case lastName = "last_name"
    case email
    case phone
    case mobile
    case isPrimaryContact = "is_primary_contact"
  }

  public init(
    contactPersonId: String? = nil,
    salutation: String? = nil,
    firstName: String? = nil,
    lastName: String? = nil,
    email: String? = nil,
    phone: String? = nil,
    mobile: String? = nil,
    isPrimaryContact: Bool? = nil
  ) {
    self.contactPersonId = contactPersonId
    self.salutation = salutation
    self.firstName = firstName
    self.lastName = lastName
    self.email = email
    self.phone = phone
    self.mobile = mobile
    self.isPrimaryContact = isPrimaryContact
  }
}

// MARK: - Create Request

/// Request to create a new contact
public struct ZBContactCreateRequest: Codable, Sendable {
  public var contactName: String
  public var companyName: String?
  public var contactType: String
  public var billingAddress: ZBAddress?
  public var shippingAddress: ZBAddress?
  public var contactPersons: [ZBContactPerson]?
  public var currencyCode: String?
  public var notes: String?
  public var website: String?
  public var taxId: String?

  enum CodingKeys: String, CodingKey {
    case contactName = "contact_name"
    case companyName = "company_name"
    case contactType = "contact_type"
    case billingAddress = "billing_address"
    case shippingAddress = "shipping_address"
    case contactPersons = "contact_persons"
    case currencyCode = "currency_code"
    case notes
    case website
    case taxId = "tax_id"
  }

  public init(
    contactName: String,
    companyName: String? = nil,
    contactType: String,
    billingAddress: ZBAddress? = nil,
    shippingAddress: ZBAddress? = nil,
    contactPersons: [ZBContactPerson]? = nil,
    currencyCode: String? = nil,
    notes: String? = nil,
    website: String? = nil,
    taxId: String? = nil
  ) {
    self.contactName = contactName
    self.companyName = companyName
    self.contactType = contactType
    self.billingAddress = billingAddress
    self.shippingAddress = shippingAddress
    self.contactPersons = contactPersons
    self.currencyCode = currencyCode
    self.notes = notes
    self.website = website
    self.taxId = taxId
  }
}

/// Contact type constants
public enum ZBContactType: String, Sendable {
  case customer
  case vendor
}
