# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
swift build
swift test
swift test --filter VLDiscogsClientTests
```

## What this is

A Swift 6 async/await client for the Discogs API, OAuth 1.0a-authenticated. `VLDiscogsClient` is a Swift `actor` — create one instance and share it. Built on top of (in dependency order) `VLDebugLogger` → `VLNetworkingClient` → `VLOAuthFlowCoordinator`/`VLOAuthProvider`; see each of those repos' own CLAUDE.md for what they actually do. This package wires them together and adds the Discogs-specific API surface (`Public/APIs/*`) and models (`Public/Models/*`).

## Architecture

`VLDiscogsClient` (the actor, `Public/VLDiscogsClient.swift`) exposes one API object per Discogs API area as a public property: `userCollectionApi`, `userIdentityApi`, `databaseApi`, `marketplaceApi`, `inventoryExportApi`, `inventoryUploadApi`, `wantlistApi`, `userListsApi`. Every method on these is `async throws`.

Two initializers, both driving OAuth setup: `init(oauthCallbackUrl:accountIdentifier:)` and `init(deepLinkCallback:accountIdentifier:)`. **Multi-account support is real**: pass an `AccountIdentifier(username:)` to scope stored tokens to a specific Discogs account, letting multiple accounts coexist in the same app (backed by `VLOAuthFlowCoordinator`'s per-account Keychain storage — see that repo's CLAUDE.md).

### Auth is lazy and callback-driven — plan the integration accordingly

Per the README: "the first request that requires a signed token triggers the OAuth flow" — you don't explicitly kick off sign-in yourself; it happens on first authenticated call, opening the Discogs authorization page via the system browser session. When the callback URL fires back into your app, **you must explicitly call `client.copyAndClearTemporaryTokens()`** in your URL handler to complete the exchange — this is a real integration step, not something that happens automatically just because the callback URL was received. Missing this call means the flow silently never completes.

### How OAuth signing actually gets wired into the request pipeline

`VLNetworkingClient` (the transport layer) has no knowledge of OAuth or Discogs at all by design — it only ships generic example interceptors (Bearer-token auth, a blind sliding-window rate limiter, logging, caching). `VLDiscogsClient` builds the actual Discogs-specific signing itself, in `Private/`:

- **`OAuthInterceptor`** — conforms to `VLNetworkingClient`'s `Interceptor` protocol. On each outgoing request, calls into an `OAuthTokenManager` to get a signed request; on a 401 response, refreshes the token and retries (via `InterceptorError.shouldRetryRequest`); on 403, just refreshes.
- **`OAuthTokenManager`** — a thin adapter wrapping `VLOAuthFlowCoordinator.OAuthFlowCoordinator`. `getSignedRequest` calls straight through to `oauthFlowCoordinator.getSignedRequest(from:)`; `refreshToken()` actually re-runs `startOAuthFlow` (i.e. "refresh" here can mean re-prompting the user via the web auth session, not a silent token refresh).
- **`NetworkClientManager`** — constructs the real `AsyncNetworkClient` with an `InterceptorChain` of `[rateLimitThrottle, rateLimitStatusInterceptor, logging, oauthInterceptor]` (in that order — throttle runs *before* OAuth signing so any wait doesn't stale out the signature's nonce/timestamp), and a *separate* unauthenticated `AsyncNetworkClient` (logging only) used internally by the `OAuthFlowCoordinator` itself for the request-token/access-token exchange calls (which obviously can't be OAuth-signed yet).

### Rate limiting is wired up — fixed-rate throttle plus a read-only adaptive-throttling hook

`NetworkClientManager` adds `VLNetworkingClient`'s `RateLimitInterceptor` to the authenticated chain, configurable via `maxRequestsPerMinute` on `VLDiscogsClient`'s public initializers (default 50, safely under Discogs's 60 req/min authenticated ceiling). This is a blind, fixed-rate throttle only — it has no awareness of Discogs's actual real-time rate limit state.

For that, `VLDiscogsClient.rateLimitStatus: DiscogsRateLimitStatus?` (async, actor-isolated) reports the `X-Discogs-Ratelimit`/`-Used`/`-Remaining` headers from the *most recent* authenticated response, captured by a private `RateLimitStatusInterceptor` that observes every response without altering it. This is read-only — `VLDiscogsClient` does not adapt its own throttle based on it. A consumer (e.g. VLOrganizer's `CollectionSyncService`) is expected to poll `rateLimitStatus` and back off further if `remaining` is running low, on top of the fixed-rate floor this client already enforces.

### There is no way to get the raw OAuth token/secret out of this client — confirmed at every layer

`VLDiscogsClient`'s public surface for auth is: `identity() -> UserIdentity` (calls Discogs's own `/oauth/identity` — proves a valid session exists, to the app itself, not to any third party), `clearTokens()`, `copyAndClearTemporaryTokens()`, and a `request(method:path:queryParameters:body:)` passthrough. None of these expose the token/secret, and `request()` is hardcoded to Discogs's own API host (`DiscogsOAuthProvider().apiHost`) — you cannot use it to make an OAuth-signed call to an arbitrary URL. This isn't a gap to patch by digging into `VLOAuthFlowCoordinator` either — that layer deliberately has no token getter (see its CLAUDE.md). **If some other service needs proof of Discogs authentication, it cannot come from relaying this client's credentials** — use a separate, independent auth mechanism for that (VLOrganizer bridges to Supabase via Sign in with Apple instead, precisely because of this — see VLOrganizer's ADR-005).

### Consumer credentials are injected by the consuming app — the library owns none

`VLDiscogsClient` does **not** hold any consumer key/secret. Both public initializers require `consumerKey:` and `consumerSecret:` parameters, which the consuming app must supply (register an app at discogs.com/settings/developers to obtain them). These are threaded through the private init → `networkClient(...)` helper → `ClientCredentials` and used to sign every OAuth request. There is no `DiscogsClientCredentials` type or `.default` anymore — that hardcoded-secret file was removed. Consuming apps own keeping their credentials out of source control (e.g. gitignored `.xcconfig` or CI secret injection); note these identify the *app*, not a user, and cannot be kept truly secret in a distributed binary regardless.

### `editProfile` can write to the user's real, public Discogs profile

`userIdentityApi.editProfile(username:name:homePage:location:profile:currAbbr:)` is a real, authenticated write to the user's live Discogs profile (name, bio, location, etc.) — not a sandboxed or app-local operation. Anything that authenticates via this client can mutate the user's actual public Discogs presence. Treat this capability with the same caution you'd give any credential with write access to a user's external account.

### Rate limit: this README's number is correct — 60 req/min authenticated

Confirmed against Discogs's official API docs (2026-07-13): **60 req/min for authenticated requests, 25 req/min unauthenticated**, enforced server-side per source IP as a moving average over a 60-second window (fully resets after 60s idle). A consuming app's own docs claiming otherwise (VLOrganizer's PRD previously said 240 req/min) were wrong — this README's figure was right all along. Discogs also returns `X-Discogs-Ratelimit`, `X-Discogs-Ratelimit-Used`, and `X-Discogs-Ratelimit-Remaining` on every response, explicitly intended for local adaptive throttling. As of the rate-limiting work above, `VLDiscogsClient` enforces a fixed-rate floor (default 50 req/min) and surfaces these headers via `rateLimitStatus` — the typed API methods (`collectionItemsByFolder`, etc.) still decode straight to response models and don't return headers per-call, but `rateLimitStatus` always reflects the latest authenticated response regardless of which method made it.

### Sample data

`sample_json/collection_releases.json` — a real (or realistic) captured Discogs collection-releases API response, useful for fixture-based testing without hitting the live API.
