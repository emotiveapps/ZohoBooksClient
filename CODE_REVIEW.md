# Code Review — ZohoBooksClient

*Reviewed 2026-08-16 (Claude Fable 5), at the request of the owner, as part of a review of its main consumer, ZohoAIBookkeeper. Scope: everything in `Sources/` and a skim of `Tests/`. Report only — no code changes were made in this repo.*

## Summary

**Grade: B−.** The architecture is genuinely good for a hand-rolled client: a clean actor-based core, auth composed via closures rather than baked in (`HttpService` knows nothing about Zoho), an `OAuthProviding` protocol that allows swapping token strategies, built-in client-side rate limiting, automatic 401-refresh-retry, and consistent paginated fetch loops where they exist. Models are tidy with explicit `CodingKeys` and there is real (if shallow) test coverage of encoding/decoding.

The problems cluster in three areas: **secrets in URLs**, **an interactive OAuth provider that cannot work**, and **client-side search that downloads entire collections**. None of these break the CLI use case today (manual tokens, small org), which is why they've gone unnoticed.

## Findings

Severity: 🔴 security/broken · 🟠 correctness/performance · 🟡 robustness · ⚪ minor.

### 🔴 Z1 — OAuth refresh sends `client_secret` and `refresh_token` in the URL query string
`ZohoOAuth.swift:57-71` (and the same pattern in `ZohoOAuthenticator`'s `refreshProvider`, `ZohoOAuthenticator.swift:87-98`)
`refreshAccessToken()` puts all credentials in `URLComponents.queryItems` and sends a POST with a `application/x-www-form-urlencoded` Content-Type header **and an empty body**. Zoho happens to accept query parameters, so it works — but secrets in URLs get logged by proxies, load balancers, and any URL-logging middleware, and can land in analytics. Move the parameters into the request body (the header already claims they're there). The authorization-code exchange in `ZohoOAuthenticator.loginProvider` does use the body — inconsistently but correctly; note it also doesn't percent-encode the values it string-concatenates.

### 🔴 Z2 — `ZohoOAuthenticator` can never return a token
`ZohoOAuthenticator.swift:12, 14-26, 136-146`
`cachedToken` is declared, read in `currentAccessToken` / `isAuthenticated` / `refreshAccessToken`, and **never assigned anywhere** (the comment "Cache the token from successful requests (if we can extract it)" has no code under it). Consequences:

- `ZohoBooksClient.configure()` builds the auth header from `oauth.currentAccessToken` → every request from a client using `ZohoOAuthenticator` sends `Authorization: Zoho-oauthtoken ` (empty).
- `isAuthenticated` is always false; `refreshAccessToken()` always returns `""`.

The only functional path is `authenticatedRequest(for:)`, which bypasses `ZohoBooksClient` entirely. So the library's interactive login is dead code in its advertised composition. Either wire OAuthenticator's login storage through to `cachedToken` (its `LoginStorage` callbacks see the tokens) or delete the type until it's real. Worth fixing before the ZohoAIBookkeeper iOS app grows a proper web-login flow — which it will want; manual token entry is its clunkiest remaining UX.

### 🟠 Z3 — Search helpers download entire collections to find one record
`ZohoBooksClient.swift:144-147, 339-342, 368-371, 403-406`
`searchContactByName` calls `fetchContacts` — which paginates through *every* contact, 200 at a time — then filters in memory; same pattern for accounts, items, and taxes. `getOrCreateVendor` does this on every save. For an org with 2,000 contacts that's 10 API calls (out of a 100/min budget) per vendor lookup. Zoho supports server-side search parameters (`contact_name`/`contact_name_contains` on `/contacts`, `filter_by`/`search_text` elsewhere) — use them and fall back to a paged scan only if needed. (ZohoAIBookkeeper currently papers over this with per-session caches in `HistoryMatcher`.)

### 🟠 Z4 — Half the list endpoints silently truncate at one page
`ZohoBooksClient.swift:152-155 (invoices), 280-283 (payments), 303-306 (chart of accounts), 347-350 (items), 376-379 (taxes)`
Contacts, expenses, and bank transactions paginate; invoices, payments, accounts, items, and taxes fetch page 1 only and return whatever came back. Past ~200 records, results are silently incomplete — the worst failure mode for a bookkeeping tool because nothing errors. Extract the paginate-loop into one generic helper (`fetchAllPages`) and use it everywhere; that also removes the three near-identical loops that already exist.

### 🟡 Z5 — Unbounded 429 retry recursion; `rateLimited` error is unreachable
`HttpService.swift:146-159, 314-328`
On 429 the request sleeps 60s and recurses with no attempt cap — a persistent 429 (e.g. daily API quota exhausted, which Zoho also signals with 429) loops forever, and each cycle deepens the stack. `HttpServiceError.rateLimited` (and `ZohoError.rateLimited`) can never actually be thrown. Add a bounded retry count, throw `rateLimited` when exceeded, and prefer honoring a `Retry-After` header over the fixed 60s.

### 🟡 Z6 — Refreshed tokens are lost between runs unless the caller opts in
`ZohoOAuth.swift:14, 96-99`
`onTokenRefresh` exists precisely so callers can persist rotated tokens, but nothing sets it in the consuming app — every CLI run starts from the config-file access token (usually expired), eats a 401, and refreshes again. Works because Zoho's refresh tokens are long-lived; breaks the day Zoho rotates the refresh token in a response (`refreshToken` *is* updated in memory, then discarded at exit). Consider making persistence harder to forget: document it loudly, or accept a `TokenStore` protocol in the initializer instead of an optional closure.

### 🟡 Z7 — Inconsistent `code != 0` checking and dead error cases
`ZohoBooksClient.swift` throughout
Create/categorize/bank endpoints check the Zoho envelope `code`; the list endpoints (`fetchContacts`, `fetchExpenses`, `fetchInvoices`, …) don't. Zoho mostly pairs application errors with non-2xx statuses so this rarely bites, but the asymmetry is a trap for the next endpoint added. Similarly, `ZohoError.decodingError` and `.networkError` exist but nothing maps `DecodingError`/`URLError` into them — callers get raw Foundation errors instead of the library's own error type.

### ⚪ Minor
- **Z8** — `checkRateLimit` (`HttpService.swift:44-63`) records the request timestamp *before* sleeping and uses `try?` on `Task.sleep`, so cancellation is swallowed and the recorded time skews early under load. Cosmetic at 100 req/min.
- **Z9** — `verbose` logging prints to stdout; when the consumer is a raw-mode TUI (the bookkeeper CLI), that corrupts the screen. stderr would compose better.
- **Z10** — `ZohoOAuthenticator.authorize()`/`refreshAccessToken()` trigger auth via a throwaway GET to `/books/v3/contacts` without an `organization_id`, which Zoho rejects — harmless for triggering the OAuth dance, but a confusing side effect to leave undocumented.
- **Z11** — Tests cover model round-trips and error descriptions only; `HttpService` logic (401-refresh-retry, 429 handling, pagination) is untested and is exactly where a `URLProtocol` mock would pay off.
- **Z12** — The working tree has an uncommitted `ZohoBooksClient.xcodeproj/project.pbxproj` change (~231 lines, likely Xcode auto-churn). Commit or discard it deliberately.
- **Z13** — `README`/`ROADMAP` promise more than the code delivers around interactive OAuth (see Z2); worth reconciling whichever direction you take.

## Suggested order of attack

1. **Z1** (move refresh params into the POST body — small, removes the secret-leak).
2. **Z4** (generic pagination helper; silent truncation is the scariest correctness issue).
3. **Z3** (server-side search; biggest performance win for the bookkeeper's save path).
4. **Z5 + Z7** (bounded retries, consistent error surface).
5. **Z2/Z6** together when the iOS app takes on real web login — that's the natural moment to make `ZohoOAuthenticator` real and add token persistence.
