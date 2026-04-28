# VL (Very Light 🪶) Discogs Client

A Swift 6 async/await client for the [Discogs API](https://www.discogs.com/developers/), built with full concurrency safety and OAuth 1.0a authentication.

## Requirements

- iOS 26+ / macOS (via Xcode workspace with local package dependencies)
- Swift 6
- Xcode 26+

## Installation

VLDiscogsClient is distributed as a Swift Package. Add it to your project via Xcode or `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/langdon78/VLDiscogsClient", .upToNextMajor(from: "1.0.0"))
]
```

Then add `VLDiscogsClient` as a dependency of your target.

> **Note:** VLDiscogsClient depends on `VLNetworkingClient` and `VLOAuthFlowCoordinator`. These are resolved automatically when using the package URL above.

## Configuration

Before using the client you need a Discogs application registered at [discogs.com/settings/developers](https://www.discogs.com/settings/developers). The app consumer key and secret are currently embedded in the library — replace the values in `DiscogsClientCredentials.swift` with your own before shipping.

## Quick Start

`VLDiscogsClient` is a Swift `actor`. Create it once (e.g. in your app's dependency container) and share it across your app.

```swift
import VLDiscogsClient

// Using a deep link callback URL (recommended for iOS)
let client = try await VLDiscogsClient(
    deepLinkCallback: OAuthDeepLinkCallbackUrl(
        scheme: "myapp",
        host: "discogs-callback"
    )
)

// Or with a full callback URL
let client = try await VLDiscogsClient(
    oauthCallbackUrl: URL(string: "myapp://discogs-callback")!
)
```

### Multi-user support

Pass an `AccountIdentifier` to scope stored OAuth tokens to a specific user. This allows multiple Discogs accounts to coexist in the same app.

```swift
let client = try await VLDiscogsClient(
    deepLinkCallback: OAuthDeepLinkCallbackUrl(scheme: "myapp", host: "discogs-callback"),
    accountIdentifier: AccountIdentifier(username: "vinylhead42")
)
```

## Authentication

VLDiscogsClient uses OAuth 1.0a. Authentication is handled automatically — the first request that requires a signed token triggers the OAuth flow, which opens the Discogs authorization page in a browser session. After the user approves access, the callback URL brings them back to your app.

### Handling the callback

When your app receives the deep link callback, hand it off to the client to complete the token exchange:

```swift
// In your scene/app delegate URL handler
try await client.copyAndClearTemporaryTokens()
```

### Signing out

```swift
try await client.clearTokens()
```

## API Reference

All API groups are available as properties on `VLDiscogsClient`. Every method is `async throws`.

---

### User Identity — `userIdentityApi`

```swift
// Authenticated user's identity
let identity = try await client.userIdentityApi.getIdentity()

// Public profile
let profile = try await client.userIdentityApi.getProfile(username: "vinylhead42")

// Edit the authenticated user's profile
let updated = try await client.userIdentityApi.editProfile(username: "vinylhead42", location: "Chicago")

// Submissions and contributions
let submissions = try await client.userIdentityApi.getSubmissions(username: "vinylhead42")
let contributions = try await client.userIdentityApi.getContributions(username: "vinylhead42", sort: "year", sortOrder: "desc")
```

---

### Database — `databaseApi`

```swift
// Releases, masters, artists, labels
let release = try await client.databaseApi.release(id: 249504)
let master  = try await client.databaseApi.master(id: 5427)
let artist  = try await client.databaseApi.artist(id: 45)
let label   = try await client.databaseApi.label(id: 1)

// Paginated sub-resources
let versions = try await client.databaseApi.masterVersions(masterId: 5427, page: 1, perPage: 50)
let releases = try await client.databaseApi.artistReleases(artistId: 45, sort: .year, sortOrder: .desc)
let catalog  = try await client.databaseApi.labelReleases(labelId: 1, page: 2)

// Release ratings
let rating = try await client.databaseApi.releaseRating(releaseId: 249504, username: "vinylhead42")
try await client.databaseApi.updateReleaseRating(releaseId: 249504, username: "vinylhead42", rating: 5)
try await client.databaseApi.deleteReleaseRating(releaseId: 249504, username: "vinylhead42")
let community = try await client.databaseApi.communityReleaseRating(releaseId: 249504)

// Search
let results = try await client.databaseApi.search(query: "Boards of Canada", type: .master, page: 1)
```

---

### User Collection — `userCollectionApi`

```swift
// Folders
let folders = try await client.userCollectionApi.collectionFolders()
let folder  = try await client.userCollectionApi.collectionFolder(folderId: 1)
let new     = try await client.userCollectionApi.createFolder(name: "Ambient")
try await client.userCollectionApi.deleteFolder(folderId: 3)

// Items
let items = try await client.userCollectionApi.collectionItemsByFolder(
    folderId: 0,
    page: 1,
    perPage: 100,
    sort: .artist,
    sortOrder: .asc
)
let byRelease = try await client.userCollectionApi.collectionItemsByRelease(releaseId: 249504)

// Add / rate / remove
let added = try await client.userCollectionApi.addReleaseToFolder(releaseId: 249504, folderId: 1)
try await client.userCollectionApi.changeRating(folderId: 1, releaseId: 249504, instanceId: added.instance_id, rating: 4)
try await client.userCollectionApi.deleteReleaseInstance(folderId: 1, releaseId: 249504, instanceId: added.instance_id)

// Custom fields
let fields = try await client.userCollectionApi.customFields()

// Collection value
let value = try await client.userCollectionApi.collectionValue()
```

---

### Wantlist — `wantlistApi`

```swift
let wants = try await client.wantlistApi.wantlist(username: "vinylhead42", page: 1)

let item = try await client.wantlistApi.addToWantlist(
    username: "vinylhead42",
    releaseId: 249504,
    notes: "Original pressing only",
    rating: 0
)

try await client.wantlistApi.editWantlistItem(username: "vinylhead42", releaseId: 249504, rating: 4)
try await client.wantlistApi.deleteFromWantlist(username: "vinylhead42", releaseId: 249504)
```

---

### Marketplace — `marketplaceApi`

```swift
// Inventory
let inventory = try await client.marketplaceApi.inventory(
    username: "vinylhead42",
    status: .forSale,
    sort: .price,
    sortOrder: .asc
)

// Listings
let listing = try await client.marketplaceApi.listing(id: 1234567)

let created = try await client.marketplaceApi.createListing(
    releaseId: 249504,
    condition: .veryGoodPlus,
    sleeveCondition: .veryGood,
    price: 24.99,
    status: .forSale,
    comments: "Plays perfectly, light sleeve wear"
)

try await client.marketplaceApi.editListing(
    id: created.listing_id,
    releaseId: 249504,
    condition: .veryGoodPlus,
    price: 19.99,
    status: .forSale
)

try await client.marketplaceApi.deleteListing(id: created.listing_id)

// Orders
let orders = try await client.marketplaceApi.orders(status: .paymentReceived)
let order  = try await client.marketplaceApi.order(id: "1-1234567")
let updated = try await client.marketplaceApi.editOrder(id: "1-1234567", status: .shipped)

let messages = try await client.marketplaceApi.orderMessages(orderId: "1-1234567")
try await client.marketplaceApi.createOrderMessage(orderId: "1-1234567", message: "Shipped today!")

// Fee calculator
let fee = try await client.marketplaceApi.fee(price: 24.99)
let feeUSD = try await client.marketplaceApi.fee(price: 24.99, currency: "USD")

// Pricing
let suggestions = try await client.marketplaceApi.priceSuggestions(releaseId: 249504)
let nmPrice = suggestions[.nearMint]   // Price? via typed subscript
let stats   = try await client.marketplaceApi.releaseStatistics(releaseId: 249504)
```

---

### User Lists — `userListsApi`

```swift
let lists = try await client.userListsApi.lists(username: "vinylhead42")
let list  = try await client.userListsApi.list(id: 12345)

for item in list.items {
    print("\(item.type): \(item.display_title ?? "")")
}
```

---

### Inventory Export — `inventoryExportApi`

```swift
// Request a new export and poll until finished
let export = try await client.inventoryExportApi.requestExport()

// Check status
let status = try await client.inventoryExportApi.export(id: export.id)
print(status.exportStatus) // .finished, .inProgress, .failed

// Download as Data
let csvData = try await client.inventoryExportApi.downloadExport(id: export.id)

// Or stream directly to a file
let destination = URL.documentsDirectory.appending(path: "inventory.csv")
let savedURL = try await client.inventoryExportApi.downloadExport(id: export.id, to: destination)
```

---

### Inventory Upload — `inventoryUploadApi`

Uploads accept the three Discogs CSV inventory types: `add`, `change`, and `delete`.

```swift
// From a file URL
try await client.inventoryUploadApi.upload(type: .add, fileURL: csvFileURL)

// From in-memory Data
let csv: Data = buildCSV()
try await client.inventoryUploadApi.upload(type: .change, csvData: csv, filename: "updates.csv")

// Check status
let recent = try await client.inventoryUploadApi.recentUploads()
let upload = try await client.inventoryUploadApi.upload(id: recent.items.first!.id)
print(upload.results?.processed ?? 0, "listings processed")
```

---

## Raw Requests

For anything not covered by a typed API method, use the escape hatch on the client directly:

```swift
let response = try await client.request(
    method: "GET",
    path: "/releases/249504",
    queryParameters: [URLQueryItem(name: "curr_abbr", value: "USD")],
    body: nil
)
let release = try response.decode(Release.self)
```

## Error Handling

All methods throw `NetworkError` from `VLNetworkingClient`:

```swift
do {
    let release = try await client.databaseApi.release(id: 249504)
} catch NetworkError.notFound {
    // 404
} catch NetworkError.unauthorized {
    // 401 — trigger re-auth
} catch NetworkError.tooManyRequests {
    // 429 — Discogs rate limit hit, back off
} catch {
    print(error)
}
```

Discogs enforces a rate limit of 60 requests per minute for authenticated users. `VLNetworkingClient` includes automatic retry with exponential backoff for transient failures.

## License

MIT
