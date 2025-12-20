//
//  NetworkClient.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator

actor NetworkClientManager: Sendable {
    var client: AsyncNetworkClientProtocol
    let tokenManager: OAuthTokenManager
    let tokenStatusStream: AsyncStream<Bool>
    
    init(
        authConfiguration: AuthConfiguration
    ) {
        let unauthenticatedClient = AsyncNetworkClient(
            interceptorChain: InterceptorChain(
                interceptors: [InterceptorFactory.make(configuration: .logging(logger: DiscogsLogger.default))]
            )
        )
        
        let oauthFlowCoordinator = OAuthFlowCoordinator(
            authConfiguration: authConfiguration,
            networkProvider: OAuthNetworkProvider(asyncNetworkClient: unauthenticatedClient)
        )
        
        self.tokenManager = OAuthTokenManager(
            oauthFlowCoordinator: oauthFlowCoordinator
        )
        
        self.tokenStatusStream = tokenManager.tokenStatusStream
        
        let oauthInterceptor = OAuthInterceptor(tokenManager: tokenManager)
        
        self.client = AsyncNetworkClient(
            interceptorChain: InterceptorChain(
                interceptors: [
                    InterceptorFactory.make(configuration: .logging(logger: DiscogsLogger.default)),
                    oauthInterceptor
                ]
            )
        )
    }
    
    func clearToken() async {
        await tokenManager.clearToken()
    }
    
    func setOnTokenRefresh(_ clearCache: @escaping (@Sendable () async -> Void)) async {
        await tokenManager.setOnTokenRefresh(clearCache)
    }
}
