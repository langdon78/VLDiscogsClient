//
//  WantlistAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/27/26.
//

import Foundation
import VLNetworkingClient

public struct WantlistAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Wantlist

    /// Get a user's wantlist
    public func wantlist(
        username: String,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> WantlistResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.wantlist(username: username, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(WantlistResponse.self)
    }

    /// Add a release to a user's wantlist
    @discardableResult
    public func addToWantlist(
        username: String,
        releaseId: Int,
        notes: String? = nil,
        rating: Int? = nil
    ) async throws -> WantItem {
        var body: [String: Any] = [:]
        if let notes { body["notes"] = notes }
        if let rating { body["rating"] = rating }
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.wantlistItem(username: username, releaseId: releaseId).url,
            method: .PUT,
            body: bodyData
        )
        return try await client.request(for: config).decode(WantItem.self)
    }

    /// Edit a wantlist item's notes or rating
    @discardableResult
    public func editWantlistItem(
        username: String,
        releaseId: Int,
        notes: String? = nil,
        rating: Int? = nil
    ) async throws -> WantItem {
        var body: [String: Any] = [:]
        if let notes { body["notes"] = notes }
        if let rating { body["rating"] = rating }
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.wantlistItem(username: username, releaseId: releaseId).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(WantItem.self)
    }

    /// Remove a release from a user's wantlist
    public func deleteFromWantlist(username: String, releaseId: Int) async throws {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.wantlistItem(username: username, releaseId: releaseId).url,
            method: .DELETE
        )
        _ = try await client.request(for: config)
    }
}

// MARK: - Response Models

/// Paginated wantlist response
public struct WantlistResponse: Codable, Sendable {
    public let pagination: Pagination
    public let wants: [WantItem]

    public init(pagination: Pagination, wants: [WantItem]) {
        self.pagination = pagination
        self.wants = wants
    }
}

/// A single item in a user's wantlist
public struct WantItem: Codable, Sendable, Identifiable {
    public let id: Int
    public let resource_url: String
    public let rating: Int
    public let notes: String?
    public let date_added: String?
    public let basic_information: WantBasicInformation

    public init(
        id: Int,
        resource_url: String,
        rating: Int,
        notes: String? = nil,
        date_added: String? = nil,
        basic_information: WantBasicInformation
    ) {
        self.id = id
        self.resource_url = resource_url
        self.rating = rating
        self.notes = notes
        self.date_added = date_added
        self.basic_information = basic_information
    }
}

/// Basic release information embedded in a wantlist item
public struct WantBasicInformation: Codable, Sendable {
    public let id: Int
    public let title: String
    public let year: Int
    public let resource_url: String
    public let thumb: String?
    public let cover_image: String?
    public let formats: [ReleaseFormat]
    public let labels: [CollectionLabel]
    public let artists: [CollectionArtist]
    public let genres: [String]?
    public let styles: [String]?

    public init(
        id: Int,
        title: String,
        year: Int,
        resource_url: String,
        thumb: String? = nil,
        cover_image: String? = nil,
        formats: [ReleaseFormat],
        labels: [CollectionLabel],
        artists: [CollectionArtist],
        genres: [String]? = nil,
        styles: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.resource_url = resource_url
        self.thumb = thumb
        self.cover_image = cover_image
        self.formats = formats
        self.labels = labels
        self.artists = artists
        self.genres = genres
        self.styles = styles
    }
}
