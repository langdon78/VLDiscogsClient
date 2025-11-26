//
//  DiscogsUserIdentity.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/24/25.
//

public struct UserIdentity: Codable, Sendable {
    public var id: Int
    public var username: String
    public var resource_url: String
    public var consumer_name: String
}
