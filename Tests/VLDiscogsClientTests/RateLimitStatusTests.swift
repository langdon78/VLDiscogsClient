//
//  RateLimitStatusTests.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 7/13/26.
//

import Testing
import Foundation
@testable import VLDiscogsClient

@Suite("DiscogsRateLimitStatus header parsing")
struct DiscogsRateLimitStatusTests {

    @Test("Parses well-formed Discogs rate-limit headers")
    func testParsesValidHeaders() throws {
        let status = DiscogsRateLimitStatus(headers: [
            "X-Discogs-Ratelimit": "60",
            "X-Discogs-Ratelimit-Used": "12",
            "X-Discogs-Ratelimit-Remaining": "48"
        ])

        let unwrapped = try #require(status)
        #expect(unwrapped.limit == 60)
        #expect(unwrapped.used == 12)
        #expect(unwrapped.remaining == 48)
    }

    @Test("Header lookup is case-insensitive")
    func testCaseInsensitiveHeaders() throws {
        let status = DiscogsRateLimitStatus(headers: [
            "x-discogs-ratelimit": "60",
            "x-discogs-ratelimit-used": "1",
            "x-discogs-ratelimit-remaining": "59"
        ])

        #expect(status != nil)
    }

    @Test("Returns nil when any header is missing")
    func testMissingHeaderReturnsNil() {
        let status = DiscogsRateLimitStatus(headers: [
            "X-Discogs-Ratelimit": "60",
            "X-Discogs-Ratelimit-Used": "12"
            // Remaining is missing
        ])

        #expect(status == nil)
    }

    @Test("Returns nil for non-Discogs responses with unrelated headers")
    func testUnrelatedHeadersReturnNil() {
        let status = DiscogsRateLimitStatus(headers: ["Content-Type": "application/json"])
        #expect(status == nil)
    }
}

@Suite("RateLimitStatusInterceptor")
struct RateLimitStatusInterceptorTests {

    private func makeResponse(headers: [String: String]) -> HTTPURLResponse {
        HTTPURLResponse(
            url: URL(string: "https://api.discogs.com/users/testuser/collection/folders")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: headers
        )!
    }

    @Test("Captures rate limit status from a real response and passes data through unchanged")
    func testCapturesStatus() async throws {
        let interceptor = RateLimitStatusInterceptor()
        let response = makeResponse(headers: [
            "X-Discogs-Ratelimit": "60",
            "X-Discogs-Ratelimit-Used": "5",
            "X-Discogs-Ratelimit-Remaining": "55"
        ])
        let originalData = "payload".data(using: .utf8)

        let returnedData = try await interceptor.intercept(response, data: originalData)

        #expect(returnedData == originalData)
        let status = await interceptor.latestStatus
        #expect(status?.limit == 60)
        #expect(status?.used == 5)
        #expect(status?.remaining == 55)
    }

    @Test("Leaves latestStatus nil when headers are absent")
    func testNoHeadersLeavesStatusNil() async throws {
        let interceptor = RateLimitStatusInterceptor()
        let response = makeResponse(headers: [:])

        _ = try await interceptor.intercept(response, data: nil)

        let status = await interceptor.latestStatus
        #expect(status == nil)
    }

    @Test("Later responses overwrite the earlier captured status")
    func testLatestStatusOverwritesPrevious() async throws {
        let interceptor = RateLimitStatusInterceptor()

        _ = try await interceptor.intercept(makeResponse(headers: [
            "X-Discogs-Ratelimit": "60",
            "X-Discogs-Ratelimit-Used": "1",
            "X-Discogs-Ratelimit-Remaining": "59"
        ]), data: nil)

        _ = try await interceptor.intercept(makeResponse(headers: [
            "X-Discogs-Ratelimit": "60",
            "X-Discogs-Ratelimit-Used": "2",
            "X-Discogs-Ratelimit-Remaining": "58"
        ]), data: nil)

        let status = await interceptor.latestStatus
        #expect(status?.used == 2)
        #expect(status?.remaining == 58)
    }

    @Test("Passthrough on request phase leaves the request unmodified")
    func testRequestPassthrough() async throws {
        let interceptor = RateLimitStatusInterceptor()
        let request = URLRequest(url: URL(string: "https://api.discogs.com/oauth/identity")!)

        let result = try await interceptor.intercept(request)

        #expect(result == request)
    }
}
