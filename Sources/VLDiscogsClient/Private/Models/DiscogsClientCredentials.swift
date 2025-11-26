//
//  DiscogsClientCredentials.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/24/25.
//

struct DiscogsClientCredentials {
    var key: String
    var secret: String
}

// TODO: - Remove hardcoded credentials
extension DiscogsClientCredentials {
    static let `default`: DiscogsClientCredentials = DiscogsClientCredentials(
        key: "kzEElKbERzmeWJlJiYbf",
        secret: "MZmlgOnBtlabrKqChwMWsQNYQvCLnEkt"
    )
}
