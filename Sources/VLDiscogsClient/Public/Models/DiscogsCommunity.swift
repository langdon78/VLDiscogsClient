//
//  DiscogsCommunity.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Community statistics for a release
public struct DiscogsCommunity: Codable, Sendable {
    public let status: String?
    public let rating: DiscogsRating?
    public let have: Int?
    public let want: Int?
    public let submitter: DiscogsCommunityUser?
    public let contributors: [DiscogsCommunityUser]?
    public let data_quality: String?

    public init(
        status: String? = nil,
        rating: DiscogsRating? = nil,
        have: Int? = nil,
        want: Int? = nil,
        submitter: DiscogsCommunityUser? = nil,
        contributors: [DiscogsCommunityUser]? = nil,
        data_quality: String? = nil
    ) {
        self.status = status
        self.rating = rating
        self.have = have
        self.want = want
        self.submitter = submitter
        self.contributors = contributors
        self.data_quality = data_quality
    }
}

/// Rating information
public struct DiscogsRating: Codable, Sendable {
    public let count: Int
    public let average: Double

    public init(count: Int, average: Double) {
        self.count = count
        self.average = average
    }
}

/// User reference
public struct DiscogsCommunityUser: Codable, Sendable {
    public let username: String
    public let resource_url: String

    public init(username: String, resource_url: String) {
        self.username = username
        self.resource_url = resource_url
    }
}
