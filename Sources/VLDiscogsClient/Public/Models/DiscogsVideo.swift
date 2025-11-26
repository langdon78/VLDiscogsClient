//
//  DiscogsVideo.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Represents a video associated with a release or master
public struct DiscogsVideo: Codable, Sendable {
    public let uri: String
    public let title: String
    public let description: String
    public let duration: Int  // in seconds
    public let embed: Bool

    public init(
        uri: String,
        title: String,
        description: String,
        duration: Int,
        embed: Bool
    ) {
        self.uri = uri
        self.title = title
        self.description = description
        self.duration = duration
        self.embed = embed
    }
}
