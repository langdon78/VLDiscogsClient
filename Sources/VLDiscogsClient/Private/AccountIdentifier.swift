//
//  AccountIdentifier.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/25/25.
//

import Foundation

/// Uniquely identifies a Discogs account
public struct AccountIdentifier: Hashable, Codable, Sendable {
    public let username: String
    
    public init(username: String) {
        self.username = username
    }
    
    /// A storage-safe key for this account
    var storageKey: String {
        "discogs_account_\(username)"
    }
}

/// Represents a stored account with its metadata
public struct StoredAccount: Codable, Sendable {
    public let identifier: AccountIdentifier
    public let userIdentity: UserIdentity
    public let lastActive: Date
    
    public init(identifier: AccountIdentifier, userIdentity: UserIdentity, lastActive: Date = Date()) {
        self.identifier = identifier
        self.userIdentity = userIdentity
        self.lastActive = lastActive
    }
}
