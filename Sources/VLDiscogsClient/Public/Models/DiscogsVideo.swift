//
//  DiscogsVideo.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Represents a video associated with a release or master.
///
/// `title` and `description` are user-contributed on Discogs and come back
/// as JSON `null` when the contributor left them blank — both were
/// previously non-optional `String`, which made one blank video
/// description fail the entire `Release` decode (VLOrganizer VIN-333, a
/// real release in the wild). `uri`/`duration`/`embed` are structural and
/// stay required; an entry violating even those is dropped by
/// `LossyDecodableArray` rather than failing the response.
public struct DiscogsVideo: Codable, Sendable {
    public let uri: String
    public let title: String?
    public let description: String?
    public let duration: Int  // in seconds
    public let embed: Bool

    public init(
        uri: String,
        title: String?,
        description: String?,
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
