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
    var onTokenRefresh: (@Sendable () async -> Void)?
    
    init(tokenManager: OAuthTokenManager, onTokenRefresh: (@Sendable () -> Void)? = nil) {
        self.tokenManager = tokenManager
        self.onTokenRefresh = onTokenRefresh
    }
    
    func intercept(_ request: URLRequest) async throws -> URLRequest {
        let signedRequest = try await tokenManager.getSignedRequest(request: request)
        return signedRequest
    }
    
    func setOnTokenRefresh(_ onTokenRefresh: (@Sendable () async -> Void)?) {
        self.onTokenRefresh = onTokenRefresh
    }
    
    func intercept(_ response: URLResponse, data: Data?) async throws -> Data? {
        // Handle 401 & 403 responses by refreshing token
        if let httpResponse = response as? HTTPURLResponse {
            switch httpResponse.statusCode {
            case 401, 403:
                try await refreshTokenAndRetry()
            default:
                return data
            }
        }
        return data
    }
    
    func refreshTokenAndRetry() async throws {
        do {
            await onTokenRefresh?()
            try await tokenManager.refreshToken()
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
