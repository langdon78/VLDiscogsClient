//
//  OAuthNetworkProvider.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/24/25.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import VLNetworkingClient
import VLOAuthFlowCoordinator

class OAuthNetworkProvider: NetworkProvider {
    let asyncNetworkClient: AsyncNetworkClientProtocol
    
    init(asyncNetworkClient: AsyncNetworkClientProtocol) {
        self.asyncNetworkClient = asyncNetworkClient
    }
    
    func getRequestToken(from request: URLRequest) async throws -> VLOAuthFlowCoordinator.OAuthRequestToken? {
        let requestConfiguration = RequestConfiguration(
            url: request.url!,
            headers: request.allHTTPHeaderFields ?? [:]
        )
        let response: NetworkResponse = try await asyncNetworkClient.request(for: requestConfiguration)
        return try response.decode(OAuthRequestToken.self, using: RequestTokenResponseDecoder())
    }
    
    func getAccessToken(from request: URLRequest) async throws -> VLOAuthFlowCoordinator.OAuthAccessToken? {
        let requestConfiguration = RequestConfiguration(
            url: request.url!,
            headers: request.allHTTPHeaderFields ?? [:]
        )
        let response: NetworkResponse = try await asyncNetworkClient.request(for: requestConfiguration)
        return try response.decode(OAuthAccessToken.self, using: AccessTokenResponseDecoder())
    }
    
    func decodeVerifierResponse(
        from authorizationResponseQuery: String
    ) throws -> VLOAuthFlowCoordinator.OAuthVerifier? {
        let decoder = VerifierResponseDecoder()
        return try decoder.decode(OAuthVerifier.self, from: authorizationResponseQuery)
    }
}
