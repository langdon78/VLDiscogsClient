//
//  DiscogsImage.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Represents an image in the Discogs database
public struct DiscogsImage: Codable, Sendable {
    public let type: String  // "primary" or "secondary"
    public let uri: String
    public let resource_url: String
    public let uri150: String
    public let width: Int
    public let height: Int

    public init(
        type: String,
        uri: String,
        resource_url: String,
        uri150: String,
        width: Int,
        height: Int
    ) {
        self.type = type
        self.uri = uri
        self.resource_url = resource_url
        self.uri150 = uri150
        self.width = width
        self.height = height
    }
}
