//
//  CollectionReleases.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/26/25.
//

import Foundation

/// Response containing user's collection releases
public struct CollectionReleasesResponse: Codable, Sendable {
    public let pagination: Pagination
    public let releases: [CollectionRelease]

    public init(pagination: Pagination, releases: [CollectionRelease]) {
        self.pagination = pagination
        self.releases = releases
    }
}

/// Individual release in a user's collection
public struct CollectionRelease: Codable, Sendable, Identifiable {
    public let id: Int
    public let instance_id: Int
    public let rating: Int
    public let basic_information: BasicInformation
    public let folder_id: Int?
    public let date_added: String

    public init(
        id: Int,
        instance_id: Int,
        rating: Int,
        basic_information: BasicInformation,
        folder_id: Int?,
        date_added: String
    ) {
        self.id = id
        self.instance_id = instance_id
        self.rating = rating
        self.basic_information = basic_information
        self.folder_id = folder_id
        self.date_added = date_added
    }
}

/// Basic information about a release in a collection
public struct BasicInformation: Codable, Sendable {
    public let id: Int
    public let title: String
    public let year: Int
    public let resource_url: String
    public let thumb: String
    /// The larger cover image Discogs returns alongside `thumb`'s fixed
    /// 150×150 collection-list size — was entirely unmodeled before
    /// (VIN-88 in the consuming VLOrganizer app), same "Codable silently
    /// drops unmapped keys" gap as `genres`/`styles` below had. Optional
    /// since it's unconfirmed whether every release response includes it.
    public let cover_image: String?
    public let artists: [CollectionArtist]
    public let labels: [CollectionLabel]
    public let formats: [ReleaseFormat]
    /// Present on live Discogs API responses (confirmed 2026-07-14 against a
    /// real collection release) but was missing from this model entirely —
    /// Codable silently drops unmapped JSON keys, so this was previously
    /// unrecoverable even though the API returned it.
    public let genres: [String]?
    public let styles: [String]?

    public init(
        id: Int,
        title: String,
        year: Int,
        resource_url: String,
        thumb: String,
        cover_image: String? = nil,
        artists: [CollectionArtist],
        labels: [CollectionLabel],
        formats: [ReleaseFormat],
        genres: [String]? = nil,
        styles: [String]? = nil
    ) {
        self.id = id
        self.title = title
        self.year = year
        self.resource_url = resource_url
        self.thumb = thumb
        self.cover_image = cover_image
        self.artists = artists
        self.labels = labels
        self.formats = formats
        self.genres = genres
        self.styles = styles
    }
}

/// Artist information in a collection release
public struct CollectionArtist: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let anv: String
    public let join: String
    public let role: String
    public let tracks: String
    public let resource_url: String

    public init(
        id: Int,
        name: String,
        anv: String,
        join: String,
        role: String,
        tracks: String,
        resource_url: String
    ) {
        self.id = id
        self.name = name
        self.anv = anv
        self.join = join
        self.role = role
        self.tracks = tracks
        self.resource_url = resource_url
    }
}

/// Label information in a collection release
public struct CollectionLabel: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let catno: String
    public let entity_type: String
    public let entity_type_name: String
    public let resource_url: String

    public init(
        id: Int,
        name: String,
        catno: String,
        entity_type: String,
        entity_type_name: String,
        resource_url: String
    ) {
        self.id = id
        self.name = name
        self.catno = catno
        self.entity_type = entity_type
        self.entity_type_name = entity_type_name
        self.resource_url = resource_url
    }
}

/// Format information for a release
public struct ReleaseFormat: Codable, Sendable {
    public let name: String
    public let qty: String
    public let descriptions: [String]

    public init(
        name: String,
        qty: String,
        descriptions: [String]
    ) {
        self.name = name
        self.qty = qty
        self.descriptions = descriptions
    }
}
