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
}
