//
//  NetworkClient.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator
import VLDebugLogger

actor NetworkClientManager: Sendable {
    var client: AsyncNetworkClientProtocol
    let tokenManager: OAuthTokenManager
    let accountIdentifier: AccountIdentifier?
    
    init(
        authConfiguration: AuthConfiguration,
        accountIdentifier: AccountIdentifier? = nil
    ) {
        self.accountIdentifier = accountIdentifier

        let unauthenticatedClient = AsyncNetworkClient(
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
