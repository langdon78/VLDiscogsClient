// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import VLOAuthFlowCoordinator
import VLNetworkingClient

public actor VLDiscogsClient: ObservableObject {
    let networkClientManager: NetworkClientManager
    let userCache: Cache<UserIdentity>
    public let userCollectionApi: UserCollectionAPI
    
    public let tokenStatusStream: AsyncStream<Bool>
    
    public init(
        oauthCallbackUrl: URL
    ) async throws {
        try await self.init(callbackUrl: oauthCallbackUrl)
    }
    
    public init(deepLinkCallback: OAuthDeepLinkCallbackUrl) async throws {
        try await self.init(callbackUrl: deepLinkCallback.url)
    }
    
    private init(callbackUrl: URL) async throws {
        let networkClientManager = VLDiscogsClient.networkClient(callbackUrl: callbackUrl)
        self.networkClientManager = networkClientManager
        let cache = await UserCache(userIdentityProvider: Self.userIdentityProvider(from: networkClientManager.client))
        self.userCache = cache
        
        await networkClientManager.setOnTokenRefresh {
            await cache.clear()
        }
        self.userCollectionApi = await UserCollectionAPI(
            client: networkClientManager.client,
            userCache: userCache
        )
        self.tokenStatusStream = networkClientManager.tokenStatusStream
    }
    
    static private func userIdentityProvider(from client: AsyncNetworkClientProtocol?) -> (() async throws -> UserIdentity) {
        return {
            guard let client else { throw NetworkError.noData }
            let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
            let response: NetworkResponse<UserIdentity> = try await client.request(for: config, with: JSONDecoder())
            guard let identity = response.data else { throw NetworkError.noData }
            return identity
        }
    }
    
    static private func networkClient(callbackUrl: URL) -> NetworkClientManager {
        NetworkClientManager(
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
    


    public func getUsername() async throws -> String {
        let user = try await userCache.get()
        return user.username
    }

    public func clearCachedUsername() async throws {
        await userCache.clear()
    }
    
    public func logoutUser() async throws {
        await networkClientManager.clearToken()
    }
    
    public func isUserLoggedIn() async -> Bool {
        await userCache.cached
    }

    // MARK: - Database Endpoints

    /// Fetch a release by ID
//    public func release(id: Int) async throws -> Release {
//        let config = RequestConfiguration(url: DiscogsEndpoint.release(id: id).url)
//        let response: NetworkResponse<Release> = try await networkClient.default.request(for: config, with: JSONDecoder())
//        guard let release = response.data else { throw NetworkError.noData }
//        return release
//    }
//
//    /// Fetch an artist by ID
//    public func artist(id: Int) async throws -> Artist {
//        let config = RequestConfiguration(url: DiscogsEndpoint.artist(id: id).url)
//        let response: NetworkResponse<Artist> = try await networkClient.default.request(for: config, with: JSONDecoder())
//        guard let artist = response.data else { throw NetworkError.noData }
//        return artist
//    }
//
//    /// Fetch a label by ID
//    public func label(id: Int) async throws -> Label {
//        let config = RequestConfiguration(url: DiscogsEndpoint.label(id: id).url)
//        let response: NetworkResponse<Label> = try await networkClient.default.request(for: config, with: JSONDecoder())
//        guard let label = response.data else { throw NetworkError.noData }
//        return label
//    }
//
//    /// Fetch a master release by ID
//    public func master(id: Int) async throws -> Master {
//        let config = RequestConfiguration(url: DiscogsEndpoint.master(id: id).url)
//        let response: NetworkResponse<Master> = try await networkClient.default.request(for: config, with: JSONDecoder())
//        guard let master = response.data else { throw NetworkError.noData }
//        return master
//    }
//
//    /// Search the Discogs database
//    public func search(
//        query: String,
//        type: DiscogsEndpoint.SearchType? = nil,
//        page: Int? = nil,
//        perPage: Int? = nil
//    ) async throws -> SearchResults {
//        let config = RequestConfiguration(
//            url: DiscogsEndpoint.search(query: query, type: type, page: page, perPage: perPage).url
//        )
//        let response: NetworkResponse<SearchResults> = try await networkClient.default.request(for: config, with: JSONDecoder())
//        guard let results = response.data else { throw NetworkError.noData }
//        return results
//    }
}
