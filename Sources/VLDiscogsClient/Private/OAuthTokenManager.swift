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
    
    init(oauthFlowCoordinator: OAuthFlowCoordinator) {
        self.oauthFlowCoordinator = oauthFlowCoordinator
    }
    
    func getSignedRequest(request: URLRequest) async throws -> URLRequest {
        try await oauthFlowCoordinator.getSignedRequest(from: request)
    }
    
    func refreshToken() async throws {
        try await oauthFlowCoordinator.startOAuthFlow(prefersEphemeralWebBrowserSession: true)
    }
}
