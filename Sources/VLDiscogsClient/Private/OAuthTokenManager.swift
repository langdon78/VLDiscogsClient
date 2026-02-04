//
//  OAuthTokenManager.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
import VLNetworkingClient
import VLOAuthFlowCoordinator
import VLDebugLogger

class OAuthTokenManager: @unchecked Sendable {
    var oauthFlowCoordinator: OAuthFlowCoordinator
    let logger: VLDebugLogger
    
    init(oauthFlowCoordinator: OAuthFlowCoordinator, logger: VLDebugLogger = VLDebugLogger.shared) {
        self.oauthFlowCoordinator = oauthFlowCoordinator
        self.logger = logger
    }
    
    func getSignedRequest(request: URLRequest) async throws -> URLRequest {
        try await oauthFlowCoordinator.getSignedRequest(from: request)
    }
    
    func refreshToken() async throws {
        try await oauthFlowCoordinator.startOAuthFlow(prefersEphemeralWebBrowserSession: true)
    }
    
    func clearTokens() async throws {
        if try await oauthFlowCoordinator.activeAccountHasValidTokens() {
            try await oauthFlowCoordinator.clearActiveTokens()
            logger.log("Removed Discogs user access token")
        }
    }
    
    func copyAndClearTemporaryTokens() async throws {
        try await oauthFlowCoordinator.copyAnonymousTokensToActiveAccount()
        try await oauthFlowCoordinator.clearAnonymousTokens()
    }

}
