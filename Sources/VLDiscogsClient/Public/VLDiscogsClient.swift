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
    
    /// Whether the OAuth authorization page opens in a private browsing
    /// session, isolated from Safari's cookies.
    ///
    /// Defaults to `false`, which is what almost every app wants: the
    /// sheet shares Safari's cookie jar, so a user already signed in to
    /// Discogs there gets a one-tap Authorize instead of a login form,
    /// and a cookie-consent banner they've already dismissed stays
    /// dismissed. iOS shows its standard "wants to use discogs.com to
    /// Sign In" alert in this mode, which is the trade.
    ///
    /// Pass `true` only when isolation is the point — authorizing an
    /// account other than the one the browser is signed in to, or a test
    /// harness that must start from no session. Be aware of the cost:
    /// an ephemeral session has no cookies at all, so *every*
    /// authorization shows Discogs's consent banner and a full login,
    /// and nothing the user does can make that stop.
    public init(
        consumerKey: String,
        consumerSecret: String,
        oauthCallbackUrl: URL,
        accountIdentifier: AccountIdentifier? = nil,
        maxRequestsPerMinute: Int = 50,
        prefersEphemeralWebBrowserSession: Bool = false
    ) async throws {
        try await self.init(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: oauthCallbackUrl,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
        )
    }

    public init(
        consumerKey: String,
        consumerSecret: String,
        deepLinkCallback: OAuthDeepLinkCallbackUrl,
        accountIdentifier: AccountIdentifier? = nil,
        maxRequestsPerMinute: Int = 50,
        prefersEphemeralWebBrowserSession: Bool = false
    ) async throws {
        try await self.init(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: deepLinkCallback.url,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
        )
    }

    private init(
        consumerKey: String,
        consumerSecret: String,
        callbackUrl: URL,
        accountIdentifier: AccountIdentifier?,
        maxRequestsPerMinute: Int,
        prefersEphemeralWebBrowserSession: Bool
    ) async throws {
        self.accountIdentifier = accountIdentifier
        let networkClientManager = VLDiscogsClient.networkClient(
            consumerKey: consumerKey,
            consumerSecret: consumerSecret,
            callbackUrl: callbackUrl,
            accountIdentifier: accountIdentifier,
            maxRequestsPerMinute: maxRequestsPerMinute,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
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
        maxRequestsPerMinute: Int,
        prefersEphemeralWebBrowserSession: Bool
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
            maxRequestsPerMinute: maxRequestsPerMinute,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
        )
    }
    
    public func identity() async throws -> UserIdentity {
        let client = await networkClientManager.client
        let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
        return try await client.request(for: config).decode(UserIdentity.self)
    }

    /// Whether the stored token still works — **without** presenting a
    /// login sheet if it doesn't.
    ///
    /// Same endpoint as `identity()`, and on success the same answer, so
    /// it doubles as "who am I actually authenticated as". The
    /// difference is the failure: `identity()` routes through
    /// `OAuthInterceptor`, which meets a 401 by opening an
    /// `ASWebAuthenticationSession` immediately, whereas this throws.
    ///
    /// Use it when the app needs to *know* rather than to *recover* —
    /// checking before a background sync, say, where a login sheet
    /// appearing unbidden would be worse than the problem. Recovery is
    /// then the app's to offer at a moment the user chose.
    ///
    /// `/oauth/identity` is the right probe because it requires auth
    /// outright: it answers 401 with "You must authenticate to access
    /// this resource" rather than degrading. Collection endpoints do
    /// not — a public collection answers an unauthenticated request with
    /// 200 and quietly drops the owner-only fields, which is how a
    /// revoked token can look like a successful sync.
    public func verifyAuthentication() async throws -> UserIdentity {
        let client = await networkClientManager.probeClient
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
