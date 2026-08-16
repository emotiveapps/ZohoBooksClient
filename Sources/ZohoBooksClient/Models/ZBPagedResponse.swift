import Foundation

/// A Zoho list response that can be fetched page by page.
/// Conformances let `ZohoBooksClient.fetchAllPages` drive pagination generically,
/// so no list endpoint silently truncates at one page.
protocol ZBPagedResponse: Decodable, Sendable {
  associatedtype Item: Sendable
  var code: Int { get }
  var message: String { get }
  var pageItems: [Item]? { get }
  var pageContext: ZBPageContext? { get }
}

extension ZBContactListResponse: ZBPagedResponse {
  var pageItems: [ZBContact]? { contacts }
}

extension ZBExpenseListResponse: ZBPagedResponse {
  var pageItems: [ZBExpense]? { expenses }
}

extension ZBInvoiceListResponse: ZBPagedResponse {
  var pageItems: [ZBInvoice]? { invoices }
}

extension ZBPaymentListResponse: ZBPagedResponse {
  var pageItems: [ZBPayment]? { customerpayments }
}

extension ZBAccountListResponse: ZBPagedResponse {
  var pageItems: [ZBAccount]? { chartOfAccounts }
}

extension ZBItemListResponse: ZBPagedResponse {
  var pageItems: [ZBItem]? { items }
}

extension ZBTaxListResponse: ZBPagedResponse {
  var pageItems: [ZBTax]? { taxes }
}

extension ZBTaxExemptionListResponse: ZBPagedResponse {
  var pageItems: [ZBTaxExemption]? { taxExemptions }
}

extension ZBBankTransactionListResponse: ZBPagedResponse {
  var pageItems: [ZBBankTransaction]? { banktransactions }
}
