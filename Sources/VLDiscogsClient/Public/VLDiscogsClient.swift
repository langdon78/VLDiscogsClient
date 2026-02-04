// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import VLOAuthFlowCoordinator
import VLNetworkingClient

public actor VLDiscogsClient: ObservableObject {
    let networkClientManager: NetworkClientManager
    public let userCollectionApi: UserCollectionAPI
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
        let response: NetworkResponse<UserIdentity> = try await client.request(for: config, with: JSONDecoder())
        guard let identity = response.data else { throw NetworkError.noData }
        return identity
    }

    public func clearTokens() async throws {
        try await networkClientManager.clearTokens()
    }
    
    public func copyAndClearTemporaryTokens() async throws {
        try await networkClientManager.copyAndClearTemporaryTokens()
    }
}
