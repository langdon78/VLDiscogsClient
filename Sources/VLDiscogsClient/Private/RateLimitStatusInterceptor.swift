//
//  RateLimitStatusInterceptor.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 7/13/26.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
import VLNetworkingClient

/// Observes every response's headers and caches the latest `DiscogsRateLimitStatus`,
/// without altering the request or response in any way. Read-only — this interceptor
/// exists purely so `VLDiscogsClient.rateLimitStatus` has something to report.
actor RateLimitStatusInterceptor: Interceptor {
    private(set) var latestStatus: DiscogsRateLimitStatus?

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        request
    }

    func intercept(_ response: URLResponse, data: Data?) async throws -> Data? {
        if let httpResponse = response as? HTTPURLResponse,
           let headers = httpResponse.allHeaderFields as? [String: String],
           let status = DiscogsRateLimitStatus(headers: headers) {
            latestStatus = status
        }
        return data
    }
}
