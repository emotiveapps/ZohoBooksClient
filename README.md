# ZohoBooksClient

A simple Zoho Books API client written in Swift.

[![Swift 6.0+](https://img.shields.io/badge/Swift-6.0+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS-blue.svg)](https://developer.apple.com)

> **Pre-alpha software (v0.1.0)** - Not intended for use in production.

## Features

- Full async/await support with Swift concurrency
- Actor-based thread-safe API client
- Automatic OAuth token refresh
- Built-in rate limiting (100 requests/minute)
- Support for all Zoho data center regions (US, EU, IN, AU, JP)
- Comprehensive model types for Zoho Books entities

### Supported Endpoints

- **Contacts** - Customers and vendors (server-side name search)
- **Invoices** - Create, fetch, and mark as sent
- **Expenses** - List (with date-range filter), detail fetch with attached documents, create, attachment upload
- **Payments** - Customer payments
- **Chart of Accounts** - Account management
- **Items** - Products and services
- **Taxes** - Tax rates and exemptions
- **Banking** - Bank accounts, transactions (all statuses or uncategorized), and categorization as expense / transfer / owner contribution / sale

All list endpoints paginate to completion — no silent truncation at one page.

### Zoho API quirks this client compensates for

Verified against the live API (Aug 2026):

- `/banktransactions` listings **exclude uncategorized statement lines** unless queried with `status=uncategorized`; `filter_by=Status.All` does not mean "all". `fetchTransactions(status: .all)` merges a second uncategorized fetch so it actually returns everything.
- `date_start`/`date_end` are **ignored** on those listings — filter by date client-side. The client still sends them in case Zoho fixes this.
- Uncategorized statement lines cannot be deleted via the API; use the `.../uncategorized/{id}/exclude` endpoint instead (reversible in the UI).

### Strict Concurrency

This library is fully compatible with Swift's strict concurrency checking. All types are marked `Sendable`, and the main classes (`ZohoBooksClient`, `ZohoOAuth`) are `actor` types which are inherently thread-safe. The project compiles cleanly with `-strict-concurrency=complete`.

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/ZohoBooksClient.git", from: "0.1.0")
]
```

Or add it via Xcode: File > Add Package Dependencies...

## Usage

### Configuration

```swift
import ZohoBooksClient

let config = ZohoConfig(
    clientId: "your-client-id",
    clientSecret: "your-client-secret",
    accessToken: "your-access-token",
    refreshToken: "your-refresh-token",
    organizationId: "your-organization-id",
    region: .com  // .com, .eu, .in, .au, or .jp
)

let client = ZohoBooksClient(config: config)
```

### Fetching Contacts

```swift
// Fetch all customers
let customers = try await client.fetchContacts(contactType: "customer")

// Search for a specific contact
if let contact = try await client.searchContactByName("Acme Corp") {
    print("Found: \(contact.contactName ?? "")")
}
```

### Creating an Invoice

```swift
let lineItems = [
    ZBInvoiceLineItemRequest(
        name: "Consulting",
        description: "Development work",
        rate: 150.0,
        quantity: 10.0
    )
]

let invoice = ZBInvoiceCreateRequest(
    customerId: "customer-id",
    invoiceNumber: "INV-001",
    date: "2024-01-15",
    lineItems: lineItems
)

let created = try await client.createInvoice(invoice)
print("Created invoice: \(created.invoiceId ?? "")")

// Mark as sent
if let invoiceId = created.invoiceId {
    try await client.markInvoiceAsSent(invoiceId)
}
```

### Creating an Expense with Attachment

```swift
let expense = ZBExpenseCreateRequest(
    accountId: "expense-account-id",
    date: "2024-01-15",
    amount: 250.50,
    description: "Office supplies"
)

let created = try await client.createExpense(expense)

// Upload receipt
if let expenseId = created.expenseId {
    let receiptData = try Data(contentsOf: receiptURL)
    try await client.uploadExpenseAttachment(
        expenseId: expenseId,
        fileData: receiptData,
        filename: "receipt.pdf"
    )
}
```

### Token Refresh Callback

You can persist refreshed tokens by setting a callback:

```swift
let client = ZohoBooksClient(config: config)

await client.oauthManager.onTokenRefresh = { accessToken, refreshToken in
    // Persist the new tokens
    await saveTokens(accessToken: accessToken, refreshToken: refreshToken)
}
```

## Requirements

- Swift 5.9+
- macOS 12+ / iOS 15+ / tvOS 15+ / watchOS 8+

## Zoho API Documentation

For more information about the Zoho Books API, see:
- [Zoho Books API Documentation](https://www.zoho.com/books/api/v3/)
- [OAuth 2.0 Authentication](https://www.zoho.com/books/api/v3/oauth/)

## License

MIT License - See LICENSE file for details.
