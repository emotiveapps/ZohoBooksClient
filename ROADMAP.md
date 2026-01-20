# Roadmap

This document outlines planned features and improvements for ZohoBooksClient, based on a comparison with the comprehensive [Weble/ZohoBooksApi](https://github.com/Weble/ZohoBooksApi) PHP library.

## Current Status (v0.1.0)

The following modules are currently supported:

- Contacts (customers and vendors)
- Invoices
- Expenses (with attachment upload)
- Customer Payments
- Chart of Accounts
- Items
- Taxes and Tax Exemptions

This library originated as a FreshBooks-to-Zoho migration tool, which is why some CRUD operations are missing in v0.1.0.

## CRUD Coverage for Existing Modules

| Entity | Create | Read (List) | Read (Single) | Update | Delete |
|--------|:------:|:-----------:|:-------------:|:------:|:------:|
| **Contacts** | ✅ | ✅ | ✅ search | ❌ | ❌ |
| **Invoices** | ✅ | ✅ | ✅ search | ❌ | ❌ |
| **Expenses** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Payments** | ✅ | ✅ | ❌ | ❌ | ❌ |
| **Accounts** | ✅ | ✅ | ✅ search | ✅ | ❌ |
| **Items** | ✅ | ✅ | ✅ search | ❌ | ❌ |
| **Taxes** | ✅ | ✅ | ✅ search | ❌ | ❌ |
| **TaxExemptions** | ❌ | ✅ | ❌ | ❌ | ❌ |

**Special actions supported:**
- `markInvoiceAsSent` - Mark invoice as sent without emailing
- `uploadExpenseAttachment` - Upload receipt/attachment to expense
- `getServiceTaxExemption` - Find service-related tax exemption

**Planned CRUD improvements:**
- Add **Update** methods for: Contacts, Invoices, Expenses, Payments, Items, Taxes
- Add **Delete** methods for all entities
- Add **Get by ID** methods (currently using search-by-name)

## Modules Comparison

| Module | PHP Library | ZohoBooksClient |
|--------|:-----------:|:---------------:|
| **Contacts** | ✅ | ✅ |
| **Invoices** | ✅ | ✅ |
| **Expenses** | ✅ | ✅ |
| **CustomerPayments** | ✅ | ✅ |
| **ChartOfAccounts** | ✅ | ✅ |
| **Items** | ✅ | ✅ |
| **Taxes** | ✅ | ✅ |
| **TaxExemptions** | ✅ | ✅ |
| BankAccounts | ✅ | ❌ |
| BankRules | ✅ | ❌ |
| BankTransactions | ✅ | ❌ |
| BaseCurrencyAdjustment | ✅ | ❌ |
| Bills | ✅ | ❌ |
| CreditNotes | ✅ | ❌ |
| Documents | ✅ | ❌ |
| Estimates | ✅ | ❌ |
| Journals | ✅ | ❌ |
| Organizations | ✅ | ❌ |
| Projects | ✅ | ❌ |
| PurchaseOrders | ✅ | ❌ |
| RecurringExpenses | ✅ | ❌ |
| RecurringInvoices | ✅ | ❌ |
| SalesOrders | ✅ | ❌ |
| Users | ✅ | ❌ |
| VendorCredits | ✅ | ❌ |
| VendorPayments | ✅ | ❌ |

## Settings Submodules Comparison

| Setting | PHP Library | ZohoBooksClient |
|---------|:-----------:|:---------------:|
| Taxes | ✅ | ✅ |
| TaxExemptions | ✅ | ✅ |
| AutoReminders | ✅ | ❌ |
| ManualReminders | ✅ | ❌ |
| Currencies | ✅ | ❌ |
| OpeningBalances | ✅ | ❌ |
| Preferences | ✅ | ❌ |
| TaxAuthorities | ✅ | ❌ |
| TaxGroups | ✅ | ❌ |

## Planned Modules

### High Priority

These modules are commonly needed for accounting integrations:

- **Bills** - Vendor bills/invoices
- **VendorPayments** - Payments to vendors
- **Estimates** - Quotes and estimates
- **CreditNotes** - Customer credit notes
- **RecurringInvoices** - Automated recurring billing

### Medium Priority

- **BankAccounts** - Bank account management
- **BankTransactions** - Bank transaction imports and matching
- **PurchaseOrders** - Purchase order workflow
- **SalesOrders** - Sales order workflow
- **Projects** - Project tracking and billing

### Lower Priority

- **BankRules** - Automated transaction categorization rules
- **BaseCurrencyAdjustment** - Multi-currency adjustments
- **Documents** - Document attachments
- **Journals** - Manual journal entries
- **Organizations** - Multi-org management
- **RecurringExpenses** - Automated recurring expenses
- **Users** - User management
- **VendorCredits** - Vendor credit notes

### Settings Submodules

- **Currencies** - Currency management
- **AutoReminders** - Automated payment reminders
- **ManualReminders** - Manual reminder templates
- **OpeningBalances** - Opening balance configuration
- **Preferences** - Organization preferences
- **TaxAuthorities** - Tax authority management
- **TaxGroups** - Compound tax groups

## Contributing

Contributions are welcome! If you'd like to help implement any of these modules, please open an issue or pull request.
