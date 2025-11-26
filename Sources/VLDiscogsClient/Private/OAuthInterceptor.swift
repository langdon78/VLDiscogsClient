//
//  OAuthInterceptor.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/26/25.
//
import VLNetworkingClient
import Foundation

final class OAuthInterceptor: Interceptor {
    
    private let tokenManager: OAuthTokenManager
    
    init(tokenManager: OAuthTokenManager) {
        self.tokenManager = tokenManager
    }
    
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        let signedRequest = try await tokenManager.getSignedRequest(request: request)
        return signedRequest
    }
    
    func intercept(_ response: URLResponse, data: Data?) async throws -> Data? {
        // Handle 401 responses by refreshing token
        if let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 401 {
            try await tokenManager.refreshToken()
            // Could throw a custom error to trigger request retry
            throw InterceptorError.cancelled
        }
        return data
    }
}
