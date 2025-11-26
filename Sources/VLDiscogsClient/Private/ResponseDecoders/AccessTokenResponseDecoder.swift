//
//  AccessTokenResponseDecoder.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/18/25.
//

import Foundation
import VLNetworkingClient
import VLOAuthFlowCoordinator

final class AccessTokenResponseDecoder: ResponseBodyDecoder, OAuthResponseParser {
    
    func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let responseString = String(data: data, encoding: .utf8) else { throw NetworkError.noData }
        let params = parseOAuthResponse(responseString)
        return OAuthAccessToken(
            token: params["oauth_token"] ?? "",
            tokenSecret: params["oauth_token_secret"] ?? ""
        ) as! T
    }
    
}
