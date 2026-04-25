# User Identity API

The User Identity API provides access to Discogs user information, including identity, profiles, submissions, and contributions.

## Overview

The `UserIdentityAPI` struct provides methods to:
- Get the authenticated user's identity
- Retrieve and edit user profiles
- View user submissions (releases, labels, artists they've added)
- View user contributions (edits to existing items)

## Usage

### Initialize the API

```swift
let client: AsyncNetworkClientProtocol = // your network client
let api = UserIdentityAPI(client: client)
```

### Get Authenticated User Identity

Retrieve basic information about the authenticated user:

```swift
let identity = try await api.getIdentity()
print("Username: \(identity.username)")
print("User ID: \(identity.id)")
print("App: \(identity.consumer_name)")
```

**Response:**
```swift
DiscogsIdentity(
    id: 12345,
    username: "vinylcollector",
    resource_url: "https://api.discogs.com/users/vinylcollector",
    consumer_name: "MyDiscogsApp"
)
```

### Get User Profile

Retrieve detailed profile information for any user:

```swift
let profile = try await api.getProfile(username: "vinylcollector")
print("Name: \(profile.name ?? "N/A")")
print("Collection size: \(profile.num_collection ?? 0)")
print("Location: \(profile.location ?? "N/A")")
print("Average rating: \(profile.rating_avg ?? 0)")
```

**Response includes:**
- Basic info (username, name, location, homepage)
- Statistics (collection size, wantlist size, ratings)
- Marketplace info (buyer/seller ratings)
- URLs (collection, wantlist, inventory)

### Edit User Profile

Update the authenticated user's profile (requires OAuth):

```swift
let updatedProfile = try await api.editProfile(
    username: "vinylcollector",
    name: "John Doe",
    homePage: "https://mywebsite.com",
    location: "San Francisco, CA",
    profile: "I love collecting rare jazz records!",
    currAbbr: "USD"
)
```

You can update individual fields:

```swift
// Update only the profile text
let profile = try await api.editProfile(
    username: "vinylcollector",
    profile: "Updated bio"
)

// Update location and homepage
let profile = try await api.editProfile(
    username: "vinylcollector",
    location: "Los Angeles, CA",
    homePage: "https://newsite.com"
)
```

### Get User Submissions

View releases, labels, and artists a user has added to Discogs:

```swift
let submissions = try await api.getSubmissions(
    username: "vinylcollector",
    page: 1,
    perPage: 50
)

print("Total submissions: \(submissions.pagination.items)")

// Access different submission types
if let releases = submissions.submissions.releases {
    for release in releases {
        print("Release: \(release.title ?? "Unknown") (\(release.year ?? 0))")
    }
}

if let labels = submissions.submissions.labels {
    for label in labels {
        print("Label: \(label.name ?? "Unknown")")
    }
}

if let artists = submissions.submissions.artists {
    for artist in artists {
        print("Artist: \(artist.name ?? "Unknown")")
    }
}
```

### Get User Contributions

View edits a user has made to existing releases, labels, and artists:

```swift
let contributions = try await api.getContributions(
    username: "vinylcollector",
    page: 1,
    perPage: 50,
    sort: "year",
    sortOrder: "desc"
)

print("Total contributions: \(contributions.pagination.items)")

for contribution in contributions.contributions {
    let name = contribution.title ?? contribution.name ?? "Unknown"
    print("\(contribution.type ?? "Unknown"): \(name)")
}
```

## Data Models

### DiscogsIdentity

Basic authenticated user information:

```swift
struct DiscogsIdentity {
    let id: Int
    let username: String
    let resource_url: String
    let consumer_name: String
}
```

### DiscogsUser

Complete user profile:

```swift
struct DiscogsUser {
    // Basic info
    let id: Int
    let username: String
    let name: String?
    let location: String?
    let home_page: String?
    let profile: String?
    
    // Statistics
    let num_collection: Int?
    let num_wantlist: Int?
    let num_lists: Int?
    let releases_contributed: Int?
    let releases_rated: Int?
    let rating_avg: Double?
    
    // Marketplace
    let buyer_rating: Double?
    let buyer_rating_stars: Int?
    let seller_rating: Double?
    let seller_rating_stars: Int?
    
    // URLs
    let avatar_url: String?
    let banner_url: String?
    let collection_folders_url: String?
    let wantlist_url: String?
    let inventory_url: String?
    
    // And more...
}
```

### UserSubmissionsResponse

```swift
struct UserSubmissionsResponse {
    let pagination: Pagination
    let submissions: UserSubmissions
}

struct UserSubmissions {
    let releases: [UserSubmissionItem]?
    let labels: [UserSubmissionItem]?
    let artists: [UserSubmissionItem]?
}
```

### UserContributionsResponse

```swift
struct UserContributionsResponse {
    let pagination: Pagination
    let contributions: [UserContribution]
}

struct UserContribution {
    let id: Int
    let title: String?
    let name: String?
    let type: String?  // "release", "artist", "label"
    let year: Int?
    // ...
}
```

## Error Handling

All API methods throw `NetworkError` for various error conditions:

```swift
do {
    let identity = try await api.getIdentity()
} catch NetworkError.noData {
    print("No data received")
} catch NetworkError.invalidResponse {
    print("Invalid response from server")
} catch {
    print("Error: \(error)")
}
```

## Pagination

For endpoints that support pagination (submissions, contributions):

```swift
// Get first page
var currentPage = 1
let firstPage = try await api.getSubmissions(
    username: "user",
    page: currentPage,
    perPage: 50
)

print("Page \(firstPage.pagination.page) of \(firstPage.pagination.pages)")

// Check if there are more pages
if firstPage.pagination.page < firstPage.pagination.pages {
    currentPage += 1
    let nextPage = try await api.getSubmissions(
        username: "user",
        page: currentPage,
        perPage: 50
    )
}
```

## Best Practices

1. **Cache user data**: User profiles don't change frequently, consider caching them
2. **Respect rate limits**: Discogs has API rate limits, implement appropriate throttling
3. **Handle optional fields**: Many fields in `DiscogsUser` are optional, always check before use
4. **Use pagination wisely**: Request only the page size you need to display
5. **OAuth required for editing**: Profile editing requires OAuth authentication

## Example: Complete User Info Display

```swift
import SwiftUI

struct UserProfileView: View {
    let api: UserIdentityAPI
    @State private var user: DiscogsUser?
    @State private var isLoading = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else if let user = user {
                VStack(alignment: .leading) {
                    Text(user.username)
                        .font(.title)
                    
                    if let name = user.name {
                        Text(name)
                            .font(.headline)
                    }
                    
                    if let location = user.location {
                        Label(location, systemImage: "location")
                    }
                    
                    HStack {
                        Label("\(user.num_collection ?? 0)", systemImage: "square.stack.3d.up")
                        Text("Collection")
                        
                        Label("\(user.num_wantlist ?? 0)", systemImage: "heart")
                        Text("Wantlist")
                    }
                    
                    if let profile = user.profile {
                        Text(profile)
                            .font(.body)
                            .padding(.top)
                    }
                }
            }
        }
        .task {
            await loadUser()
        }
    }
    
    func loadUser() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // First get the authenticated user's identity
            let identity = try await api.getIdentity()
            
            // Then fetch their full profile
            user = try await api.getProfile(username: identity.username)
        } catch {
            print("Error loading user: \(error)")
        }
    }
}
```

## API Reference

### Methods

- `getIdentity() async throws -> DiscogsIdentity`
- `getProfile(username:) async throws -> DiscogsUser`
- `editProfile(username:name:homePage:location:profile:currAbbr:) async throws -> DiscogsUser`
- `getSubmissions(username:page:perPage:) async throws -> UserSubmissionsResponse`
- `getContributions(username:page:perPage:sort:sortOrder:) async throws -> UserContributionsResponse`

### Related APIs

- **UserCollectionAPI**: Manage user's collection folders and releases
- **UserWantlistAPI**: Manage user's wantlist (coming soon)
- **UserListsAPI**: Manage user's lists (coming soon)

## Testing

Comprehensive tests are provided in `UserIdentityAPITests.swift`:

```bash
swift test --filter UserIdentityAPITests
```

The test suite includes:
- Identity retrieval tests
- Profile management tests
- Submissions and contributions tests
- Error handling tests
- Response model encoding/decoding tests
- Integration-style workflow tests
