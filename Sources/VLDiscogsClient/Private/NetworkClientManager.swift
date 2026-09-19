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
    /// Signs like `client` but never auto-reauthenticates — see
    /// `OAuthSigningInterceptor`. Used only by `verifyAuthentication()`,
    /// so a caller can ask whether the stored token still works without
    /// that question itself presenting a login sheet.
    ///
    /// Shares the session (and therefore the connection pool) with
    /// `client`; it's the interceptor chain that differs, not the
    /// transport.
    var probeClient: AsyncNetworkClientProtocol
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
        maxRequestsPerMinute: Int = 50,
        prefersEphemeralWebBrowserSession: Bool = false
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
            oauthFlowCoordinator: oauthFlowCoordinator,
            prefersEphemeralWebBrowserSession: prefersEphemeralWebBrowserSession
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

        // Same throttle and the same rate-limit header capture — a probe
        // is a real request and shouldn't escape either. Only the OAuth
        // interceptor differs.
        self.probeClient = AsyncNetworkClient(
            session: session,
            interceptorChain: InterceptorChain(
                interceptors: [
                    InterceptorFactory.make(configuration: .rateLimit(maxRequestsPerMinute: maxRequestsPerMinute)),
                    rateLimitStatusInterceptor,
                    InterceptorFactory.make(configuration: .logging()),
                    OAuthSigningInterceptor(tokenManager: tokenManager)
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
