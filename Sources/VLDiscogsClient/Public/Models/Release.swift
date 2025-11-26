//
//  Release.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Full release information from the Discogs database
public struct Release: Codable, Sendable, Identifiable {
    public let id: Int
    public let status: String
    public let year: Int?
    public let resource_url: String
    public let uri: String
    public let artists: [ArtistReference]
    public let artists_sort: String?
    public let labels: [LabelReference]
    public let series: [String]?
    public let companies: [Company]?
    public let formats: [Format]
    public let data_quality: String
    public let community: DiscogsCommunity?
    public let format_quantity: Int
    public let date_added: String?
    public let date_changed: String?
    public let num_for_sale: Int?
    public let lowest_price: Double?
    public let master_id: Int?
    public let master_url: String?
    public let title: String
    public let country: String?
    public let released: String?
    public let notes: String?
    public let released_formatted: String?
    public let identifiers: [Identifier]?
    public let videos: [DiscogsVideo]?
    public let genres: [String]?
    public let styles: [String]?
    public let tracklist: [Track]
    public let extraartists: [ArtistReference]?
    public let images: [DiscogsImage]?
    public let thumb: String?
    public let estimated_weight: Int?
    public let blocked_from_sale: Bool?
    public let is_offensive: Bool?

    public init(
        id: Int,
        status: String,
        year: Int? = nil,
        resource_url: String,
        uri: String,
        artists: [ArtistReference],
        artists_sort: String? = nil,
        labels: [LabelReference],
        series: [String]? = nil,
        companies: [Company]? = nil,
        formats: [Format],
        data_quality: String,
        community: DiscogsCommunity? = nil,
        format_quantity: Int,
        date_added: String? = nil,
        date_changed: String? = nil,
        num_for_sale: Int? = nil,
        lowest_price: Double? = nil,
        master_id: Int? = nil,
        master_url: String? = nil,
        title: String,
        country: String? = nil,
        released: String? = nil,
        notes: String? = nil,
        released_formatted: String? = nil,
        identifiers: [Identifier]? = nil,
        videos: [DiscogsVideo]? = nil,
        genres: [String]? = nil,
        styles: [String]? = nil,
        tracklist: [Track],
        extraartists: [ArtistReference]? = nil,
        images: [DiscogsImage]? = nil,
        thumb: String? = nil,
        estimated_weight: Int? = nil,
        blocked_from_sale: Bool? = nil,
        is_offensive: Bool? = nil
    ) {
        self.id = id
        self.status = status
        self.year = year
        self.resource_url = resource_url
        self.uri = uri
        self.artists = artists
        self.artists_sort = artists_sort
        self.labels = labels
        self.series = series
        self.companies = companies
        self.formats = formats
        self.data_quality = data_quality
        self.community = community
        self.format_quantity = format_quantity
        self.date_added = date_added
        self.date_changed = date_changed
        self.num_for_sale = num_for_sale
        self.lowest_price = lowest_price
        self.master_id = master_id
        self.master_url = master_url
        self.title = title
        self.country = country
        self.released = released
        self.notes = notes
        self.released_formatted = released_formatted
        self.identifiers = identifiers
        self.videos = videos
        self.genres = genres
        self.styles = styles
        self.tracklist = tracklist
        self.extraartists = extraartists
        self.images = images
        self.thumb = thumb
        self.estimated_weight = estimated_weight
        self.blocked_from_sale = blocked_from_sale
        self.is_offensive = is_offensive
    }
}

/// Track information
public struct Track: Codable, Sendable {
    public let position: String
    public let type_: String  // "track", "index", "heading"
    public let title: String
    public let duration: String?
    public let extraartists: [ArtistReference]?

    public init(
        position: String,
        type_: String,
        title: String,
        duration: String? = nil,
        extraartists: [ArtistReference]? = nil
    ) {
        self.position = position
        self.type_ = type_
        self.title = title
        self.duration = duration
        self.extraartists = extraartists
    }
}

/// Format information (vinyl, CD, cassette, etc.)
public struct Format: Codable, Sendable {
    public let name: String
    public let qty: String
    public let descriptions: [String]?
    public let text: String?

    public init(
        name: String,
        qty: String,
        descriptions: [String]? = nil,
        text: String? = nil
    ) {
        self.name = name
        self.qty = qty
        self.descriptions = descriptions
        self.text = text
    }
}

/// Release identifiers (barcode, matrix numbers, etc.)
public struct Identifier: Codable, Sendable {
    public let type: String
    public let value: String
    public let description: String?

    public init(type: String, value: String, description: String? = nil) {
        self.type = type
        self.value = value
        self.description = description
    }
}
