//
//  OAuthBrowserSessionTests.swift
//  VLDiscogsClient
//

import Testing
import Foundation
import VLNetworkingClient
import VLOAuthProvider
import VLOAuthFlowCoordinator
import VLDebugLogger
@testable import VLDiscogsClient

/// The authorization sheet's cookie isolation, which this client used to
/// force on with a hardcoded `true` in `OAuthTokenManager.refreshToken`.
///
/// Why that mattered, reported by a beta tester of an app built on this
/// SDK: an ephemeral session has no cookies at all, so Discogs's consent
/// banner appeared on *every* authorization — accepting it did nothing
/// for next time — and it covered the Authorize button. The same
/// isolation meant the user was never signed in either, so they had to
/// type their Discogs password into the sheet despite Safari already
/// holding the session.
///
/// Sharing Safari's jar is the right default for a single-account app.
/// These tests exist to keep the default from quietly flipping back;
/// a regression is invisible in code review and only shows up as a
/// stranger's confusing first run.
///
/// The second half of the suite covers the other question about when a
/// login sheet appears: `OAuthSigningInterceptor`, which exists so an
/// app can ask "is my token still good?" without the asking itself
/// prompting.
@Suite("OAuth browser session isolation")
struct OAuthBrowserSessionTests {
    /// Never used to make a request — the flow is never started here.
    private func makeCoordinator() -> OAuthFlowCoordinator {
        let client = AsyncNetworkClient(
            session: URLSession(configuration: .ephemeral),
            interceptorChain: InterceptorChain(interceptors: [])
        )
        return OAuthFlowCoordinator(
            authConfiguration: AuthConfiguration(
                clientCredentials: ClientCredentials(key: "key", secret: "secret"),
                provider: DiscogsOAuthProvider(),
                callback: URL(string: "vltest://callback")!
            ),
            networkProvider: OAuthNetworkProvider(asyncNetworkClient: client),
            logger: VLDebugLogger.shared
        )
    }

    @Test("The sheet shares Safari's cookies unless a caller asks otherwise")
    func defaultsToASharedBrowserSession() {
        let manager = OAuthTokenManager(oauthFlowCoordinator: makeCoordinator())
        #expect(manager.prefersEphemeralWebBrowserSession == false)
    }

    @Test("Isolation is still available to callers that genuinely need it")
    func honoursAnExplicitRequestForIsolation() {
        let manager = OAuthTokenManager(
            oauthFlowCoordinator: makeCoordinator(),
            prefersEphemeralWebBrowserSession: true
        )
        #expect(manager.prefersEphemeralWebBrowserSession == true)
    }

    // MARK: - The silent probe

    /// The contract `verifyAuthentication()` rests on. `OAuthInterceptor`
    /// answers a 401 by opening a login sheet; this one has to hand the
    /// 401 back untouched so the caller can decide what to do about it.
    ///
    /// A 401 is the case that matters — it's the one the other
    /// interceptor treats as a trigger — but the hook is inert for every
    /// status, which is what "signs, and otherwise stays out of the way"
    /// means.
    @Test("A 401 passes through the signing interceptor untouched")
    func signingInterceptorDoesNotReactToAnUnauthorizedResponse() async throws {
        let interceptor = OAuthSigningInterceptor(tokenManager: OAuthTokenManager(
            oauthFlowCoordinator: makeCoordinator()
        ))
        let unauthorized = HTTPURLResponse(
            url: URL(string: "https://api.discogs.com/oauth/identity")!,
            statusCode: 401, httpVersion: nil, headerFields: nil
        )!
        let body = Data(#"{"message":"You must authenticate to access this resource."}"#.utf8)

        let returned = try await interceptor.intercept(unauthorized, data: body)

        #expect(returned == body)
    }

    @Test("A 200 passes through unchanged too")
    func signingInterceptorLeavesSuccessAlone() async throws {
        let interceptor = OAuthSigningInterceptor(tokenManager: OAuthTokenManager(
            oauthFlowCoordinator: makeCoordinator()
        ))
        let ok = HTTPURLResponse(
            url: URL(string: "https://api.discogs.com/oauth/identity")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        let body = Data(#"{"username":"someone"}"#.utf8)

        #expect(try await interceptor.intercept(ok, data: body) == body)
    }
}
