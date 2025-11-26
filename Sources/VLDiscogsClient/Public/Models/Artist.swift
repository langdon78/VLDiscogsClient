//
//  Artist.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Full artist information from the Discogs database
public struct Artist: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let resource_url: String
    public let uri: String
    public let releases_url: String
    public let images: [DiscogsImage]?
    public let realname: String?
    public let profile: String?
    public let urls: [String]?
    public let namevariations: [String]?
    public let aliases: [ArtistAlias]?
    public let groups: [ArtistGroup]?
    public let members: [ArtistMember]?
    public let data_quality: String?

    public init(
        id: Int,
        name: String,
        resource_url: String,
        uri: String,
        releases_url: String,
        images: [DiscogsImage]? = nil,
        realname: String? = nil,
        profile: String? = nil,
        urls: [String]? = nil,
        namevariations: [String]? = nil,
        aliases: [ArtistAlias]? = nil,
        groups: [ArtistGroup]? = nil,
        members: [ArtistMember]? = nil,
        data_quality: String? = nil
    ) {
        self.id = id
        self.name = name
        self.resource_url = resource_url
        self.uri = uri
        self.releases_url = releases_url
        self.images = images
        self.realname = realname
        self.profile = profile
        self.urls = urls
        self.namevariations = namevariations
        self.aliases = aliases
        self.groups = groups
        self.members = members
        self.data_quality = data_quality
    }
}

/// Artist alias information
public struct ArtistAlias: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let resource_url: String

    public init(id: Int, name: String, resource_url: String) {
        self.id = id
        self.name = name
        self.resource_url = resource_url
    }
}

/// Artist group membership
public struct ArtistGroup: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let resource_url: String
    public let active: Bool

    public init(id: Int, name: String, resource_url: String, active: Bool) {
        self.id = id
        self.name = name
        self.resource_url = resource_url
        self.active = active
    }
}

/// Artist member information
public struct ArtistMember: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let resource_url: String
    public let active: Bool?

    public init(id: Int, name: String, resource_url: String, active: Bool? = nil) {
        self.id = id
        self.name = name
        self.resource_url = resource_url
        self.active = active
    }
}

/// Simplified artist reference used in releases and tracks
public struct ArtistReference: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let anv: String?  // Artist name variation
    public let join: String?  // Join phrase (e.g., "&", "feat.")
    public let role: String?
    public let tracks: String?
    public let resource_url: String
    public let thumbnail_url: String?

    public init(
        id: Int,
        name: String,
        anv: String? = nil,
        join: String? = nil,
        role: String? = nil,
        tracks: String? = nil,
        resource_url: String,
        thumbnail_url: String? = nil
    ) {
        self.id = id
        self.name = name
        self.anv = anv
        self.join = join
        self.role = role
        self.tracks = tracks
        self.resource_url = resource_url
        self.thumbnail_url = thumbnail_url
    }
}
