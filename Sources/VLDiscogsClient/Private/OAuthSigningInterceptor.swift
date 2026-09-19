//
//  OAuthSigningInterceptor.swift
//  VLDiscogsClient
//

import VLNetworkingClient
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// `OAuthInterceptor`'s request half, without its response half.
///
/// Signs outgoing requests exactly as `OAuthInterceptor` does — same
/// `tokenManager`, same signature — but a 401 comes back to the caller as
/// a 401 instead of triggering `refreshTokenAndRetry()`, which opens an
/// `ASWebAuthenticationSession` on the spot.
///
/// That auto-recovery is the right default for a request the user asked
/// for. It is exactly wrong for a *probe*: an app checking whether its
/// stored token is still good shouldn't be able to throw a login sheet in
/// the user's face as a side effect of asking. Without this, there is no
/// way to find out — every authenticated endpoint routes through the same
/// interceptor, so `identity()`, `collectionFolders()` and the rest all
/// prompt alike.
///
/// A separate interceptor rather than a flag on `OAuthInterceptor`
/// because `Interceptor`'s response hook receives `(URLResponse, Data?)`
/// and never sees the request that produced it — there is nowhere for a
/// per-request opt-out to live.
actor OAuthSigningInterceptor: Interceptor {
    private let tokenManager: OAuthTokenManager

    init(tokenManager: OAuthTokenManager) {
        self.tokenManager = tokenManager
    }

    func intercept(_ request: URLRequest) async throws -> URLRequest {
        try await tokenManager.getSignedRequest(request: request)
    }

    /// Deliberately inert. The status code reaching the caller unchanged
    /// is the whole point of this type.
    func intercept(_ response: URLResponse, data: Data?) async throws -> Data? {
        data
    }
}
