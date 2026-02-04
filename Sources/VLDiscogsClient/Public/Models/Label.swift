//
//  Label.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Full label information from the Discogs database
public struct DiscogsLabel: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let resource_url: String
    public let uri: String
    public let releases_url: String
    public let images: [DiscogsImage]?
    public let contact_info: String?
    public let profile: String?
    public let parent_label: LabelReference?
    public let data_quality: String?
    public let urls: [String]?
    public let sublabels: [LabelReference]?

    public init(
        id: Int,
        name: String,
        resource_url: String,
        uri: String,
        releases_url: String,
        images: [DiscogsImage]? = nil,
        contact_info: String? = nil,
        profile: String? = nil,
        parent_label: LabelReference? = nil,
        data_quality: String? = nil,
        urls: [String]? = nil,
        sublabels: [LabelReference]? = nil
    ) {
        self.id = id
        self.name = name
        self.resource_url = resource_url
        self.uri = uri
        self.releases_url = releases_url
        self.images = images
        self.contact_info = contact_info
        self.profile = profile
        self.parent_label = parent_label
        self.data_quality = data_quality
        self.urls = urls
        self.sublabels = sublabels
    }
}

/// Simplified label reference used in releases
public struct LabelReference: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let catno: String?  // Catalog number
    public let entity_type: String?
    public let entity_type_name: String?
    public let resource_url: String
    public let thumbnail_url: String?

    public init(
        id: Int,
        name: String,
        catno: String? = nil,
        entity_type: String? = nil,
        entity_type_name: String? = nil,
        resource_url: String,
        thumbnail_url: String? = nil
    ) {
        self.id = id
        self.name = name
        self.catno = catno
        self.entity_type = entity_type
        self.entity_type_name = entity_type_name
        self.resource_url = resource_url
        self.thumbnail_url = thumbnail_url
    }
}

/// Company information (used in releases for rights holders, manufacturers, etc.)
public struct Company: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let catno: String?
    public let entity_type: String
    public let entity_type_name: String
    public let resource_url: String
    public let thumbnail_url: String?

    public init(
        id: Int,
        name: String,
        catno: String? = nil,
        entity_type: String,
        entity_type_name: String,
        resource_url: String,
        thumbnail_url: String? = nil
    ) {
        self.id = id
        self.name = name
        self.catno = catno
        self.entity_type = entity_type
        self.entity_type_name = entity_type_name
        self.resource_url = resource_url
        self.thumbnail_url = thumbnail_url
    }
}
