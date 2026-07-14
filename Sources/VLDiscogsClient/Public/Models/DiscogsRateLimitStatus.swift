//
//  DiscogsRateLimitStatus.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 7/13/26.
//

import Foundation

/// A snapshot of Discogs's server-reported rate limit state, parsed from the
/// `X-Discogs-Ratelimit`, `X-Discogs-Ratelimit-Used`, and `X-Discogs-Ratelimit-Remaining`
/// response headers Discogs returns on every API response.
///
/// `VLDiscogsClient` does not enforce anything based on this itself — it's a read-only
/// snapshot of the *last* authenticated response, intended for a consumer (e.g.
/// VLOrganizer's `CollectionSyncService`) to implement adaptive throttling on top of
/// the client's own fixed-rate `RateLimitInterceptor`.
public struct DiscogsRateLimitStatus: Sendable, Equatable {
    /// The total requests allowed in the current window (`X-Discogs-Ratelimit`).
    public let limit: Int
    /// Requests already made in the current window (`X-Discogs-Ratelimit-Used`).
    public let used: Int
    /// Requests remaining in the current window (`X-Discogs-Ratelimit-Remaining`).
    public let remaining: Int

    public init(limit: Int, used: Int, remaining: Int) {
        self.limit = limit
        self.used = used
        self.remaining = remaining
    }

    /// Parses the three Discogs rate-limit headers, if all are present and well-formed.
    /// Returns `nil` if any header is missing (e.g. non-Discogs responses, or responses
    /// served from a request-level cache that never hit the network).
    init?(headers: [String: String]) {
        let lookup = headers.reduce(into: [String: String]()) { result, pair in
            result[pair.key.lowercased()] = pair.value
        }
        guard
            let limitString = lookup["x-discogs-ratelimit"],
            let usedString = lookup["x-discogs-ratelimit-used"],
            let remainingString = lookup["x-discogs-ratelimit-remaining"],
            let limit = Int(limitString),
            let used = Int(usedString),
            let remaining = Int(remainingString)
        else { return nil }

        self.limit = limit
        self.used = used
        self.remaining = remaining
    }
}
