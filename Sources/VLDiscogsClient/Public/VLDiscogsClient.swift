// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import VLOAuthFlowCoordinator
import VLNetworkingClient

public actor VLDiscogsClient: ObservableObject {
    let networkClient: NetworkClient
    let userCache: Cache<UserIdentity>
    
    @Published public var loggedIn: Bool
    
    public init(
        oauthCallbackUrl: URL
    ) async {
        await self.init(callbackUrl: oauthCallbackUrl)
    }
    
    public init(deepLinkCallback: OAuthDeepLinkCallbackUrl) async {
        await self.init(callbackUrl: deepLinkCallback.url)
    }
    
    private init(callbackUrl: URL) async {
        let client = VLDiscogsClient.networkClient(callbackUrl: callbackUrl)
        self.networkClient = client
        let cache = UserCache(userIdentityProvider: Self.userIdentityProvider(from: client))
        self.userCache = cache
        
        self.loggedIn = await cache.cached
        await client.setUserCache(cache)
    }
    
    static private func userIdentityProvider(from client: NetworkClient?) -> (() async throws -> UserIdentity) {
        return {
            guard let client else { throw NetworkError.noData }
            let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
            let response: NetworkResponse<UserIdentity> = try await client.default.request(for: config, with: JSONDecoder())
            guard let identity = response.data else { throw NetworkError.noData }
            return identity
        }
    }
    
    static private func networkClient(callbackUrl: URL) -> NetworkClient {
        NetworkClient(
            authConfiguration: AuthConfiguration(
                clientCredentials: ClientCredentials(
                    key: DiscogsClientCredentials.default.key,
                    secret: DiscogsClientCredentials.default.secret
                ),
                provider: DiscogsOAuthProvider(),
                callback: callbackUrl
            )
        )
    }
    
    public func identity() async throws -> UserIdentity {
        try await userCache.get()
    }
    
    public func collectionFolders() async throws -> CollectionFolders {
        let username = try await getUsername()
        let config = RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: username).url)
        let response: NetworkResponse<CollectionFolders> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let collectionFolders = response.data else { throw NetworkError.noData }
        return collectionFolders
    }
    
    public func folderPath() -> String {
        DiscogsEndpoint.collectionFolders().url.relativePath
    }
    
    public func folderRequest() async throws -> RequestConfiguration {
        let username = try await getUsername()
        return RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: username).url)
    }
    
    public func response(for requestConfiguration: RequestConfiguration) async throws -> NetworkResponse<Data> {
        try await networkClient.default.requestRawData(for: requestConfiguration)
    }

    public func collectionItemsByRelease(
        releaseId: Int,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> CollectionReleasesResponse {
        let username = try await getUsername()
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByRelease(
                username: username,
                releaseId: releaseId,
                page: page,
                perPage: perPage
            ).url
        )
        let response: NetworkResponse<CollectionReleasesResponse> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let releases = response.data else { throw NetworkError.noData }
        return releases
    }
    
    public func collectionItemsByFolder(
        folderId: Int,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: DiscogsEndpoint.SortParameterValue? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil
    ) async throws -> CollectionReleasesResponse {
        let username = try await getUsername()
        
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByFolder(
                username: username,
                folderId: folderId,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        let response: NetworkResponse<CollectionReleasesResponse> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let releases = response.data else { throw NetworkError.noData }
        return releases
    }

    public func getUsername() async throws -> String {
        let user = try await userCache.get()
        loggedIn = await userCache.cached
        return user.username
    }

    public func clearCachedUsername() async throws {
        await userCache.clear()
    }
    
    public func logoutUser() async throws {
        loggedIn = false
        await networkClient.clearToken()
    }
    
    public func isUserLoggedIn() async -> Bool {
        await userCache.cached
    }

    // MARK: - Database Endpoints

    /// Fetch a release by ID
    public func release(id: Int) async throws -> Release {
        let config = RequestConfiguration(url: DiscogsEndpoint.release(id: id).url)
        let response: NetworkResponse<Release> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let release = response.data else { throw NetworkError.noData }
        return release
    }

    /// Fetch an artist by ID
    public func artist(id: Int) async throws -> Artist {
        let config = RequestConfiguration(url: DiscogsEndpoint.artist(id: id).url)
        let response: NetworkResponse<Artist> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let artist = response.data else { throw NetworkError.noData }
        return artist
    }

    /// Fetch a label by ID
    public func label(id: Int) async throws -> Label {
        let config = RequestConfiguration(url: DiscogsEndpoint.label(id: id).url)
        let response: NetworkResponse<Label> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let label = response.data else { throw NetworkError.noData }
        return label
    }

    /// Fetch a master release by ID
    public func master(id: Int) async throws -> Master {
        let config = RequestConfiguration(url: DiscogsEndpoint.master(id: id).url)
        let response: NetworkResponse<Master> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let master = response.data else { throw NetworkError.noData }
        return master
    }

    /// Search the Discogs database
    public func search(
        query: String,
        type: DiscogsEndpoint.SearchType? = nil,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> SearchResults {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.search(query: query, type: type, page: page, perPage: perPage).url
        )
        let response: NetworkResponse<SearchResults> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let results = response.data else { throw NetworkError.noData }
        return results
    }
}

public struct OAuthDeepLinkCallbackUrl {
    let scheme: String
    let host: String
    let path: String?
    
    public init(scheme: String, host: String, path: String? = nil) {
        self.scheme = scheme
        self.host = host
        self.path = path
    }
    
    var url: URL {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        if let path {
            components.path = path
        }
        guard let url = components.url else {
            fatalError("Unable to construct URL from scheme: \(scheme) host: \(host) path: \(path ?? "")")
        }
        return url
    }
}
