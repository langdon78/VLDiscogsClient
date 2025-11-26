//
//  SearchResults.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Search results from the Discogs database
public struct SearchResults: Codable, Sendable {
    public let pagination: Pagination
    public let results: [SearchResult]

    public init(pagination: Pagination, results: [SearchResult]) {
        self.pagination = pagination
        self.results = results
    }
}

/// Individual search result
public struct SearchResult: Codable, Sendable, Identifiable {
    public let id: Int
    public let type: String  // "release", "master", "artist", "label"
    public let title: String?
    public let country: String?
    public let year: String?
    public let format: [String]?
    public let label: [String]?
    public let genre: [String]?
    public let style: [String]?
    public let barcode: [String]?
    public let catno: String?
    public let resource_url: String
    public let uri: String?
    public let thumb: String?
    public let cover_image: String?
    public let master_id: Int?
    public let master_url: String?
    public let user_data: UserData?
    public let community: SearchCommunity?

    public init(
        id: Int,
        type: String,
        title: String? = nil,
        country: String? = nil,
        year: String? = nil,
        format: [String]? = nil,
        label: [String]? = nil,
        genre: [String]? = nil,
        style: [String]? = nil,
        barcode: [String]? = nil,
        catno: String? = nil,
        resource_url: String,
        uri: String? = nil,
        thumb: String? = nil,
        cover_image: String? = nil,
        master_id: Int? = nil,
        master_url: String? = nil,
        user_data: UserData? = nil,
        community: SearchCommunity? = nil
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.country = country
        self.year = year
        self.format = format
        self.label = label
        self.genre = genre
        self.style = style
        self.barcode = barcode
        self.catno = catno
        self.resource_url = resource_url
        self.uri = uri
        self.thumb = thumb
        self.cover_image = cover_image
        self.master_id = master_id
        self.master_url = master_url
        self.user_data = user_data
        self.community = community
    }
}

/// Pagination information
public struct Pagination: Codable, Sendable {
    public let page: Int
    public let pages: Int
    public let per_page: Int
    public let items: Int
    public let urls: PaginationUrls?

    public init(
        page: Int,
        pages: Int,
        per_page: Int,
        items: Int,
        urls: PaginationUrls? = nil
    ) {
        self.page = page
        self.pages = pages
        self.per_page = per_page
        self.items = items
        self.urls = urls
    }
}

/// Pagination URLs for navigation
public struct PaginationUrls: Codable, Sendable {
    public let last: String?
    public let next: String?
    public let first: String?
    public let prev: String?

    public init(
        last: String? = nil,
        next: String? = nil,
        first: String? = nil,
        prev: String? = nil
    ) {
        self.last = last
        self.next = next
        self.first = first
        self.prev = prev
    }
}

/// User-specific data in search results
public struct UserData: Codable, Sendable {
    public let in_wantlist: Bool?
    public let in_collection: Bool?

    public init(in_wantlist: Bool? = nil, in_collection: Bool? = nil) {
        self.in_wantlist = in_wantlist
        self.in_collection = in_collection
    }
}

/// Community data in search results
public struct SearchCommunity: Codable, Sendable {
    public let want: Int?
    public let have: Int?

    public init(want: Int? = nil, have: Int? = nil) {
        self.want = want
        self.have = have
    }
}
