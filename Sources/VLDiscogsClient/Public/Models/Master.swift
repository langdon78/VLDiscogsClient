//
//  Master.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Master release information from the Discogs database
/// A master release represents a set of similar releases (e.g., all pressings of an album)
public struct Master: Codable, Sendable, Identifiable {
    public let id: Int
    public let main_release: Int
    public let most_recent_release: Int?
    public let resource_url: String
    public let uri: String
    public let versions_url: String
    public let main_release_url: String
    public let most_recent_release_url: String?
    public let num_for_sale: Int?
    public let lowest_price: Double?
    public let images: [DiscogsImage]?
    public let genres: [String]?
    public let styles: [String]?
    public let year: Int?
    public let tracklist: [Track]
    public let artists: [ArtistReference]
    public let title: String
    public let data_quality: String?
    public let videos: [DiscogsVideo]?

    public init(
        id: Int,
        main_release: Int,
        most_recent_release: Int? = nil,
        resource_url: String,
        uri: String,
        versions_url: String,
        main_release_url: String,
        most_recent_release_url: String? = nil,
        num_for_sale: Int? = nil,
        lowest_price: Double? = nil,
        images: [DiscogsImage]? = nil,
        genres: [String]? = nil,
        styles: [String]? = nil,
        year: Int? = nil,
        tracklist: [Track],
        artists: [ArtistReference],
        title: String,
        data_quality: String? = nil,
        videos: [DiscogsVideo]? = nil
    ) {
        self.id = id
        self.main_release = main_release
        self.most_recent_release = most_recent_release
        self.resource_url = resource_url
        self.uri = uri
        self.versions_url = versions_url
        self.main_release_url = main_release_url
        self.most_recent_release_url = most_recent_release_url
        self.num_for_sale = num_for_sale
        self.lowest_price = lowest_price
        self.images = images
        self.genres = genres
        self.styles = styles
        self.year = year
        self.tracklist = tracklist
        self.artists = artists
        self.title = title
        self.data_quality = data_quality
        self.videos = videos
    }
}
