//
//  NetworkClient.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator

actor NetworkClient: Sendable {
    var `default`: AsyncNetworkClientProtocol
    var oauthFlowCoordinator: OAuthFlowCoordinator
    var userCache: Cache<UserIdentity>?
    private let oauthInterceptor: OAuthInterceptor
    
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
        
        self.oauthInterceptor = OAuthInterceptor(tokenManager: tokenManager)
        
        self.default = AsyncNetworkClient(
            interceptorChain: InterceptorChain(
                interceptors: [
                    InterceptorFactory.make(configuration: .logging(logger: DiscogsLogger.default)),
                    oauthInterceptor
                ]
            )
        )
    }
    
    func clearToken() async {
        if oauthFlowCoordinator.hasValidTokens() {
            oauthFlowCoordinator.clearToken()
            await userCache?.clear()
            DiscogsLogger.default.debug("Removed Discogs user access token")
        }
    }
    
    func setUserCache(_ cache: Cache<UserIdentity>) async {
        self.userCache = cache
        
        // Set up the token refresh callback to clear the cache
        let clearUserCache = { @Sendable [weak self] in
            guard let self else { return }
            await self.userCache!.clear()
        }
        await oauthInterceptor.setOnTokenRefresh(clearUserCache)
    }
}
