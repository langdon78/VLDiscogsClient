//
//  VerifierResponseDecoder.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
import VLNetworkingClient
import VLOAuthFlowCoordinator

final class VerifierResponseDecoder: OAuthResponseParser {
    
    func decode<T>(_ type: T.Type, from data: String) throws -> T where T : Decodable {
        let params = parseOAuthResponse(data)
        return OAuthVerifier(
            token: params["oauth_token"] ?? "",
            verifier: params["oauth_verifier"] ?? ""
        ) as! T
    }
    
}
