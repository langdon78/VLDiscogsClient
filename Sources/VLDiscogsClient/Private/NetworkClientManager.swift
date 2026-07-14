//
//  NetworkClientManager.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator
import VLDebugLogger

actor NetworkClientManager: Sendable {
    var client: AsyncNetworkClientProtocol
    let tokenManager: OAuthTokenManager
    let accountIdentifier: AccountIdentifier?
    private let rateLimitStatusInterceptor: RateLimitStatusInterceptor

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }

    init(
        authConfiguration: AuthConfiguration,
        accountIdentifier: AccountIdentifier? = nil,
        maxRequestsPerMinute: Int = 50
    ) {
        self.accountIdentifier = accountIdentifier

        let session = Self.makeSession()

        let unauthenticatedClient = AsyncNetworkClient(
            session: session,
            interceptorChain: InterceptorChain(
                interceptors: [InterceptorFactory.make(configuration: .logging())]
            )
        )

        let oauthFlowCoordinator = OAuthFlowCoordinator(
            authConfiguration: authConfiguration,
            networkProvider: OAuthNetworkProvider(asyncNetworkClient: unauthenticatedClient),
            activeAccountKey: accountIdentifier?.storageKey,
            logger: VLDebugLogger.shared
        )

        self.tokenManager = OAuthTokenManager(
            oauthFlowCoordinator: oauthFlowCoordinator
        )

        let oauthInterceptor = OAuthInterceptor(tokenManager: tokenManager)
        let rateLimitStatusInterceptor = RateLimitStatusInterceptor()
        self.rateLimitStatusInterceptor = rateLimitStatusInterceptor

        self.client = AsyncNetworkClient(
            session: session,
            interceptorChain: InterceptorChain(
                interceptors: [
                    // Throttle (and thus any wait) happens before OAuth signs the
                    // request, so the signature's nonce/timestamp stay fresh.
                    InterceptorFactory.make(configuration: .rateLimit(maxRequestsPerMinute: maxRequestsPerMinute)),
                    rateLimitStatusInterceptor,
                    InterceptorFactory.make(configuration: .logging()),
                    oauthInterceptor
                ]
            )
        )
    }

    func clearTokens() async throws {
        try await tokenManager.clearTokens()
    }

    func copyAndClearTemporaryTokens() async throws {
        try await tokenManager.copyAndClearTemporaryTokens()
    }

    var rateLimitStatus: DiscogsRateLimitStatus? {
        get async {
            await rateLimitStatusInterceptor.latestStatus
        }
    }

}
