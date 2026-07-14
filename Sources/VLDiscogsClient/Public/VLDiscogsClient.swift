import Foundation
import VLOAuthFlowCoordinator
import VLNetworkingClient

public actor VLDiscogsClient {
    let networkClientManager: NetworkClientManager
    public let userCollectionApi: UserCollectionAPI
    public let userIdentityApi: UserIdentityAPI
    public let databaseApi: DatabaseAPI
    public let marketplaceApi: MarketplaceAPI
    public let inventoryExportApi: InventoryExportAPI
    public let wantlistApi: WantlistAPI
    public let userListsApi: UserListsAPI
    public let inventoryUploadApi: InventoryUploadAPI
    public let accountIdentifier: AccountIdentifier?
    
    public init(
        consumerKey: String,
        consumerSecret: String,
        oauthCallbackUrl: URL,
        accountIdentifier: AccountIdentifier? = nil,
        maxRequestsPerMinute: Int = 50
    ) async throws {
        try await self.init(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: oauthCallbackUrl,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute
        )
    }

    public init(
        consumerKey: String,
        consumerSecret: String,
        deepLinkCallback: OAuthDeepLinkCallbackUrl,
        accountIdentifier: AccountIdentifier? = nil,
        maxRequestsPerMinute: Int = 50
    ) async throws {
        try await self.init(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: deepLinkCallback.url,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute
        )
    }

    private init(
        consumerKey: String,
        consumerSecret: String,
        callbackUrl: URL,
        accountIdentifier: AccountIdentifier?,
        maxRequestsPerMinute: Int
    ) async throws {
        self.accountIdentifier = accountIdentifier
        let networkClientManager = VLDiscogsClient.networkClient(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: callbackUrl,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute
        )
        self.networkClientManager = networkClientManager

        self.userCollectionApi = await UserCollectionAPI(
            client: networkClientManager.client,
            accountIdentifier: accountIdentifier?.username ?? ""
        )
        self.userIdentityApi = await UserIdentityAPI(client: networkClientManager.client)
        self.databaseApi = await DatabaseAPI(client: networkClientManager.client)
        self.marketplaceApi = await MarketplaceAPI(client: networkClientManager.client)
        self.inventoryExportApi = await InventoryExportAPI(client: networkClientManager.client)
        self.wantlistApi = await WantlistAPI(client: networkClientManager.client)
        self.userListsApi = await UserListsAPI(client: networkClientManager.client)
        self.inventoryUploadApi = await InventoryUploadAPI(client: networkClientManager.client)
    }
    
    static private func networkClient(
        consumerKey: String,
        consumerSecret: String,
        callbackUrl: URL,
        accountIdentifier: AccountIdentifier?,
        maxRequestsPerMinute: Int
    ) -> NetworkClientManager {
        NetworkClientManager(
            authConfiguration: AuthConfiguration(
                clientCredentials: ClientCredentials(
                    key: consumerKey,
                    secret: consumerSecret
                ),
                provider: DiscogsOAuthProvider(),
                callback: callbackUrl
            ),
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute
        )
    }
    
    public func identity() async throws -> UserIdentity {
        let client = await networkClientManager.client
        let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
        return try await client.request(for: config).decode(UserIdentity.self)
    }

    public func clearTokens() async throws {
        try await networkClientManager.clearTokens()
    }
    
    public func copyAndClearTemporaryTokens() async throws {
        try await networkClientManager.copyAndClearTemporaryTokens()
    }

    /// Discogs's server-reported rate limit state as of the most recent authenticated
    /// response, or `nil` if no authenticated request has completed yet. Intended for a
    /// caller to implement adaptive throttling on top of the client's own fixed-rate
    /// throttle (`maxRequestsPerMinute` at init) — this client does not adapt on its own.
    public var rateLimitStatus: DiscogsRateLimitStatus? {
        get async {
            await networkClientManager.rateLimitStatus
        }
    }


    public func request(
        method: String,
        path: String,
        queryParameters: [URLQueryItem],
        body: [String: Any]?
    ) async throws -> NetworkResponse {
        var url = URL(string: DiscogsOAuthProvider().apiHost)!
        url.append(path: path)
        if !queryParameters.isEmpty {
            url.append(queryItems: queryParameters)
        }
        var bodyData: Data? = nil
        if let body {
            bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
        }
        let requestConfig = RequestConfiguration(
            url: url,
            method: HTTPMethod(rawValue: method.uppercased()) ?? .GET,
            body: bodyData
        )
        return try await networkClientManager.client.request(for: requestConfig)
    }
}
