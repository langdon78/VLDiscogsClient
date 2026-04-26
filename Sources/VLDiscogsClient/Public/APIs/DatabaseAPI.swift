//
//  DatabaseAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/26/26.
//

import Foundation
import VLNetworkingClient

public struct DatabaseAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Release

    /// Get a release by ID
    public func release(id: Int) async throws -> Release {
        let config = RequestConfiguration(url: DiscogsEndpoint.release(id: id).url)
        return try await client.request(for: config).decode(Release.self)
    }

    /// Get a user's rating for a specific release
    public func releaseRating(releaseId: Int, username: String) async throws -> ReleaseRating {
        let config = RequestConfiguration(url: DiscogsEndpoint.releaseRating(releaseId: releaseId, username: username).url)
        return try await client.request(for: config).decode(ReleaseRating.self)
    }

    /// Update a user's rating for a release (1–5, or 0 to remove)
    @discardableResult
    public func updateReleaseRating(releaseId: Int, username: String, rating: Int) async throws -> ReleaseRating {
        let bodyData = try JSONSerialization.data(withJSONObject: ["rating": rating])
        let config = RequestConfiguration(
            url: DiscogsEndpoint.releaseRating(releaseId: releaseId, username: username).url,
            method: .PUT,
            body: bodyData
        )
        return try await client.request(for: config).decode(ReleaseRating.self)
    }

    /// Delete a user's rating for a release
    public func deleteReleaseRating(releaseId: Int, username: String) async throws {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.releaseRating(releaseId: releaseId, username: username).url,
            method: .DELETE
        )
        _ = try await client.request(for: config)
    }

    /// Get the community rating summary for a release
    public func communityReleaseRating(releaseId: Int) async throws -> CommunityReleaseRating {
        let config = RequestConfiguration(url: DiscogsEndpoint.communityReleaseRating(releaseId: releaseId).url)
        return try await client.request(for: config).decode(CommunityReleaseRating.self)
    }

    // MARK: - Master Release

    /// Get a master release by ID
    public func master(id: Int) async throws -> Master {
        let config = RequestConfiguration(url: DiscogsEndpoint.master(id: id).url)
        return try await client.request(for: config).decode(Master.self)
    }

    /// Get all versions of a master release
    public func masterVersions(
        masterId: Int,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> MasterVersionsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.masterVersions(masterId: masterId, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(MasterVersionsResponse.self)
    }

    // MARK: - Artist

    /// Get an artist by ID
    public func artist(id: Int) async throws -> Artist {
        let config = RequestConfiguration(url: DiscogsEndpoint.artist(id: id).url)
        return try await client.request(for: config).decode(Artist.self)
    }

    /// Get all releases for an artist
    public func artistReleases(
        artistId: Int,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: DiscogsEndpoint.SortParameterValue? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil
    ) async throws -> ArtistReleasesResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.artistReleases(
                artistId: artistId,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        return try await client.request(for: config).decode(ArtistReleasesResponse.self)
    }

    // MARK: - Label

    /// Get a label by ID
    public func label(id: Int) async throws -> DiscogsLabel {
        let config = RequestConfiguration(url: DiscogsEndpoint.label(id: id).url)
        return try await client.request(for: config).decode(DiscogsLabel.self)
    }

    /// Get all releases for a label
    public func labelReleases(
        labelId: Int,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: DiscogsEndpoint.SortParameterValue? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil
    ) async throws -> LabelReleasesResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.labelReleases(
                labelId: labelId,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        return try await client.request(for: config).decode(LabelReleasesResponse.self)
    }

    // MARK: - Search

    /// Search the Discogs database
    public func search(
        query: String,
        type: DiscogsEndpoint.SearchType? = nil,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> SearchResults {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.search(query: query, type: type, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(SearchResults.self)
    }
}

// MARK: - Response Models

/// A user's rating for a specific release
public struct ReleaseRating: Codable, Sendable {
    public let username: String
    public let release_id: Int
    public let rating: Int

    public init(username: String, release_id: Int, rating: Int) {
        self.username = username
        self.release_id = release_id
        self.rating = rating
    }
}

/// Community aggregate rating for a release
public struct CommunityReleaseRating: Codable, Sendable {
    public let release_id: Int
    public let rating: CommunityRating

    public init(release_id: Int, rating: CommunityRating) {
        self.release_id = release_id
        self.rating = rating
    }
}

public struct CommunityRating: Codable, Sendable {
    public let count: Int
    public let average: Double

    public init(count: Int, average: Double) {
        self.count = count
        self.average = average
    }
}

/// Paginated list of versions of a master release
public struct MasterVersionsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let versions: [MasterVersion]

    public init(pagination: Pagination, versions: [MasterVersion]) {
        self.pagination = pagination
        self.versions = versions
    }
}

/// A single version entry within a master release
public struct MasterVersion: Codable, Sendable, Identifiable {
    public let id: Int
    public let title: String
    public let label: String?
    public let country: String?
    public let major_formats: [String]?
    public let format: String?
    public let catno: String?
    public let released: String?
    public let status: String?
    public let resource_url: String
    public let thumb: String?
    public let stats: ReleaseStats?

    public init(
        id: Int,
        title: String,
        label: String? = nil,
        country: String? = nil,
        major_formats: [String]? = nil,
        format: String? = nil,
        catno: String? = nil,
        released: String? = nil,
        status: String? = nil,
        resource_url: String,
        thumb: String? = nil,
        stats: ReleaseStats? = nil
    ) {
        self.id = id
        self.title = title
        self.label = label
        self.country = country
        self.major_formats = major_formats
        self.format = format
        self.catno = catno
        self.released = released
        self.status = status
        self.resource_url = resource_url
        self.thumb = thumb
        self.stats = stats
    }
}

/// Paginated list of releases for an artist
public struct ArtistReleasesResponse: Codable, Sendable {
    public let pagination: Pagination
    public let releases: [ArtistRelease]

    public init(pagination: Pagination, releases: [ArtistRelease]) {
        self.pagination = pagination
        self.releases = releases
    }
}

/// A single release entry in an artist's release list
public struct ArtistRelease: Codable, Sendable, Identifiable {
    public let id: Int
    public let title: String
    public let type: String  // "master" or "release"
    public let main_release: Int?
    public let artist: String?
    public let role: String?  // "Main", "Appearance", "TrackAppearance"
    public let resource_url: String
    public let year: Int?
    public let thumb: String?
    public let stats: ReleaseStats?

    public init(
        id: Int,
        title: String,
        type: String,
        main_release: Int? = nil,
        artist: String? = nil,
        role: String? = nil,
        resource_url: String,
        year: Int? = nil,
        thumb: String? = nil,
        stats: ReleaseStats? = nil
    ) {
        self.id = id
        self.title = title
        self.type = type
        self.main_release = main_release
        self.artist = artist
        self.role = role
        self.resource_url = resource_url
        self.year = year
        self.thumb = thumb
        self.stats = stats
    }
}

/// Paginated list of releases for a label
public struct LabelReleasesResponse: Codable, Sendable {
    public let pagination: Pagination
    public let releases: [LabelRelease]

    public init(pagination: Pagination, releases: [LabelRelease]) {
        self.pagination = pagination
        self.releases = releases
    }
}

/// A single release entry in a label's release list
public struct LabelRelease: Codable, Sendable, Identifiable {
    public let id: Int
    public let title: String?
    public let format: String?
    public let catno: String?
    public let artist: String?
    public let year: Int?
    public let status: String?
    public let resource_url: String
    public let thumb: String?
    public let stats: ReleaseStats?

    public init(
        id: Int,
        title: String? = nil,
        format: String? = nil,
        catno: String? = nil,
        artist: String? = nil,
        year: Int? = nil,
        status: String? = nil,
        resource_url: String,
        thumb: String? = nil,
        stats: ReleaseStats? = nil
    ) {
        self.id = id
        self.title = title
        self.format = format
        self.catno = catno
        self.artist = artist
        self.year = year
        self.status = status
        self.resource_url = resource_url
        self.thumb = thumb
        self.stats = stats
    }
}

/// Community and user statistics for a release or master version
public struct ReleaseStats: Codable, Sendable {
    public let user: UserReleaseStats?
    public let community: CommunityReleaseStats?

    public init(user: UserReleaseStats? = nil, community: CommunityReleaseStats? = nil) {
        self.user = user
        self.community = community
    }
}

public struct UserReleaseStats: Codable, Sendable {
    public let in_wantlist: Bool?
    public let in_collection: Bool?

    public init(in_wantlist: Bool? = nil, in_collection: Bool? = nil) {
        self.in_wantlist = in_wantlist
        self.in_collection = in_collection
    }
}

public struct CommunityReleaseStats: Codable, Sendable {
    public let in_wantlist: Int?
    public let in_collection: Int?

    public init(in_wantlist: Int? = nil, in_collection: Int? = nil) {
        self.in_wantlist = in_wantlist
        self.in_collection = in_collection
    }
}
