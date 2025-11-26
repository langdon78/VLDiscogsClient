//
//  NetworkClient.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator

actor NetworkClient {
    var `default`: AsyncNetworkClientProtocol
    var oauthFlowCoordinator: OAuthFlowCoordinator
    
    init(
        authConfiguration: AuthConfiguration,
        oauthNetworkClient: AsyncNetworkClientProtocol = AsyncNetworkClient(
            interceptorChain: InterceptorChain(
                interceptors: [InterceptorFactory.make(configuration: .logging(logger: DiscogsLogger.default))]
            )
        )
    ) {
        self.oauthFlowCoordinator = OAuthFlowCoordinator(
            authConfiguration: authConfiguration,
            networkProvider: OAuthNetworkProvider(asyncNetworkClient: oauthNetworkClient)
        )
        
        let tokenManager = OAuthTokenManager(
            oauthFlowCoordinator: oauthFlowCoordinator
        )

        self.default = AsyncNetworkClient(
            interceptorChain: InterceptorChain(
                interceptors: [
                    InterceptorFactory.make(configuration: .logging(logger: DiscogsLogger.default)),
                    OAuthInterceptor(tokenManager: tokenManager)
                ]
            )
        )
    }
    
    func clearToken() async {
        if oauthFlowCoordinator.hasValidTokens() {
            oauthFlowCoordinator.clearToken()
            DiscogsLogger.default.debug("Removed Discogs user access token")
        }
    }
}
