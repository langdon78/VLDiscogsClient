//
//  NetworkClient.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator
import VLDebugLogger

actor NetworkClientManager: Sendable {
    var client: AsyncNetworkClientProtocol
    let tokenManager: OAuthTokenManager
    let accountIdentifier: AccountIdentifier?
    
    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }

    init(
        authConfiguration: AuthConfiguration,
        accountIdentifier: AccountIdentifier? = nil
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

        self.client = AsyncNetworkClient(
            session: session,
            interceptorChain: InterceptorChain(
                interceptors: [
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

}
