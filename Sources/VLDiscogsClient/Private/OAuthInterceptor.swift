//
//  OAuthInterceptor.swift
//  VLOAuthFlowCoordinator
//
//  Created by James Langdon on 8/26/25.
//
import VLNetworkingClient
import Foundation
import AuthenticationServices

actor OAuthInterceptor: Interceptor {
    
    private let tokenManager: OAuthTokenManager
    
    init(tokenManager: OAuthTokenManager) {
        self.tokenManager = tokenManager
    }
    
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        let signedRequest = try await tokenManager.getSignedRequest(request: request)
        return signedRequest
    }
    
    func intercept(_ response: URLResponse, data: Data?) async throws -> Data? {
        // Handle 401 & 403 responses by refreshing token
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 401:
                try await refreshTokenAndRetry()
            case 403:
                try await refreshToken()
            default:
                return data
            }
        }
        return data
    }
    
    func refreshToken() async throws {
        try await tokenManager.refreshToken()
    }
    
    func refreshTokenAndRetry() async throws {
        do {
            try await refreshToken()
            throw InterceptorError.shouldRetryRequest
        } catch let sessionError as ASWebAuthenticationSessionError {
            switch sessionError.code {
            case .canceledLogin:
                throw InterceptorError.cancelled
            default:
                throw InterceptorError.shouldRetryRequest
            }
        }
    }
}
