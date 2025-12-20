//
//  OAuthTokenManager.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
import VLNetworkingClient
import VLOAuthFlowCoordinator

class OAuthTokenManager: @unchecked Sendable {
    var oauthFlowCoordinator: OAuthFlowCoordinator
    var onTokenRefresh: (@Sendable () async -> Void)?
    let tokenStatusStream: AsyncStream<Bool>
    
    private let tokenStatusContinuation: AsyncStream<Bool>.Continuation
    
    init(oauthFlowCoordinator: OAuthFlowCoordinator) {
        self.oauthFlowCoordinator = oauthFlowCoordinator
        
        var continuation: AsyncStream<Bool>.Continuation!
        self.tokenStatusStream = AsyncStream<Bool> { cont in
            continuation = cont
            continuation.yield(oauthFlowCoordinator.hasValidTokens())
        }
        self.tokenStatusContinuation = continuation
    }
    
    func getSignedRequest(request: URLRequest) async throws -> URLRequest {
        try await oauthFlowCoordinator.getSignedRequest(from: request)
    }
    
    func refreshToken() async throws {
        try await oauthFlowCoordinator.startOAuthFlow(prefersEphemeralWebBrowserSession: true)
        await onTokenRefresh?()
        notifyTokenStatusChanged()
    }
    
    func setOnTokenRefresh(_ onTokenRefresh: (@Sendable () async -> Void)?) {
        self.onTokenRefresh = onTokenRefresh
    }
    
    func clearToken() async {
        if oauthFlowCoordinator.hasValidTokens() {
            oauthFlowCoordinator.clearToken()
            await onTokenRefresh?()
            notifyTokenStatusChanged()
            DiscogsLogger.default.debug("Removed Discogs user access token")
        }
    }
    
    private func notifyTokenStatusChanged() {
        tokenStatusContinuation.yield(oauthFlowCoordinator.hasValidTokens())
    }
}
