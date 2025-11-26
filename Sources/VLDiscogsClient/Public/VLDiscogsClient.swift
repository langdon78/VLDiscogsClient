// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import VLOAuthFlowCoordinator
import VLNetworkingClient

public final class VLDiscogsClient: ObservableObject {
    var networkClient: NetworkClient
    private static let usernameKey = "com.vldiscogs.cached_username"
    @Published public var loggedIn: Bool = VLDiscogsClient.isUserLoggedIn()
    
    public init(
        oauthCallbackUrl: URL
    ) {
        networkClient = VLDiscogsClient.networkClient(callbackUrl: oauthCallbackUrl)
    }
    
    public init(deepLinkCallback: OAuthDeepLinkCallbackUrl) {
        networkClient = VLDiscogsClient.networkClient(callbackUrl: deepLinkCallback.url)
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
        let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
        let response: NetworkResponse<UserIdentity> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let identity = response.data else { throw NetworkError.noData }
        return identity
    }
    
    public func collectionFolders() async throws -> CollectionFolders {
        let username = try await getUsername()
        let config = RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: username).url)
        let response: NetworkResponse<CollectionFolders> = try await networkClient.default.request(for: config, with: JSONDecoder())
        guard let collectionFolders = response.data else { throw NetworkError.noData }
        return collectionFolders
    }

    public func getUsername() async throws -> String {
        if let cached = UserDefaults.standard.string(forKey: VLDiscogsClient.usernameKey) {
            return cached
        }

        let identity = try await identity()
        UserDefaults.standard.set(identity.username, forKey: VLDiscogsClient.usernameKey)
        loggedIn = true
        return identity.username
    }

    public func clearCachedUsername() {
        if let username = UserDefaults.standard.string(forKey: VLDiscogsClient.usernameKey) {
            UserDefaults.standard.removeObject(forKey: VLDiscogsClient.usernameKey)
            DiscogsLogger.default.debug("\(username) removed from cache")
        }
    }
    
    public func logoutUser() async {
        loggedIn = false
        await networkClient.clearToken()
        clearCachedUsername()
    }
    
    public static func isUserLoggedIn() -> Bool {
        UserDefaults.standard.string(forKey: VLDiscogsClient.usernameKey) != nil
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
        type: SearchType? = nil,
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
