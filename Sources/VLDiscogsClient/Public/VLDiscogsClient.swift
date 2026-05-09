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
        oauthCallbackUrl: URL,
        accountIdentifier: AccountIdentifier? = nil
    ) async throws {
        try await self.init(callbackUrl: oauthCallbackUrl, accountIdentifier: accountIdentifier)
    }
    
    public init(
        deepLinkCallback: OAuthDeepLinkCallbackUrl,
        accountIdentifier: AccountIdentifier? = nil
    ) async throws {
        try await self.init(callbackUrl: deepLinkCallback.url, accountIdentifier: accountIdentifier)
    }
    
    private init(callbackUrl: URL, accountIdentifier: AccountIdentifier?) async throws {
        self.accountIdentifier = accountIdentifier
        let networkClientManager = VLDiscogsClient.networkClient(
            callbackUrl: callbackUrl,
            accountIdentifier: accountIdentifier
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
        callbackUrl: URL,
        accountIdentifier: AccountIdentifier?
    ) -> NetworkClientManager {
        NetworkClientManager(
            authConfiguration: AuthConfiguration(
                clientCredentials: ClientCredentials(
                    key: DiscogsClientCredentials.default.key,
                    secret: DiscogsClientCredentials.default.secret
                ),
                provider: DiscogsOAuthProvider(),
                callback: callbackUrl
            ),
            accountIdentifier: accountIdentifier
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
