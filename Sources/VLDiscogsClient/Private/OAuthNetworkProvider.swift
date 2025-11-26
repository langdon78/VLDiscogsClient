//
//  OAuthNetworkProvider.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/24/25.
//

import Foundation
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
        let response: NetworkResponse<OAuthRequestToken> = try await asyncNetworkClient.request(for: requestConfiguration, with: RequestTokenResponseDecoder())
        let requestToken = try await parseRequestTokenResponse(for: response)
        return requestToken
    }
    
    func getAccessToken(from request: URLRequest) async throws -> VLOAuthFlowCoordinator.OAuthAccessToken? {
        let requestConfiguration = RequestConfiguration(
            url: request.url!,
            headers: request.allHTTPHeaderFields ?? [:]
        )
        let response: NetworkResponse<OAuthAccessToken> = try await asyncNetworkClient.request(for: requestConfiguration, with: AccessTokenResponseDecoder())
        return response.data
    }
    
    func decodeVerifierResponse(
        from authorizationResponseQuery: String
    ) throws -> VLOAuthFlowCoordinator.OAuthVerifier? {
        let decoder = VerifierResponseDecoder()
        return try decoder.decode(OAuthVerifier.self, from: authorizationResponseQuery)
    }
    
    private func parseRequestTokenResponse(for response: NetworkResponse<OAuthRequestToken>) async throws -> OAuthRequestToken {
        guard let requestToken = try await response.data else { throw NetworkError.noData }
        return requestToken
    }
}
