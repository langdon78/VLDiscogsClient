//
//  DiscogsCollectionFolder.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//


public struct CollectionFolder: Codable, Sendable, Identifiable, Hashable {
    public var id: Int
    public var count: Int
    public var name: String
    public var resource_url: String
}

public struct CollectionFolders: Codable, Sendable {
    public var folders: [CollectionFolder]
}
