//
//  UserListsAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/27/26.
//

import Foundation
import VLNetworkingClient

public struct UserListsAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Lists

    /// Get all lists created by a user
    public func lists(
        username: String,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> UserListsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.userLists(username: username, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(UserListsResponse.self)
    }

    /// Get a list and its items by ID
    public func list(id: Int) async throws -> UserListDetail {
        let config = RequestConfiguration(url: DiscogsEndpoint.userList(listId: id).url)
        return try await client.request(for: config).decode(UserListDetail.self)
    }
}

// MARK: - Response Models

/// Paginated list of a user's lists
public struct UserListsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let lists: [UserList]

    public init(pagination: Pagination, lists: [UserList]) {
        self.pagination = pagination
        self.lists = lists
    }
}

/// A summary of a user-created list (no items)
public struct UserList: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let resource_url: String
    public let uri: String?
    public let `public`: Bool?
    public let date_added: String?
    public let date_changed: String?

    public init(
        id: Int,
        name: String,
        description: String? = nil,
        resource_url: String,
        uri: String? = nil,
        public isPublic: Bool? = nil,
        date_added: String? = nil,
        date_changed: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.resource_url = resource_url
        self.uri = uri
        self.`public` = isPublic
        self.date_added = date_added
        self.date_changed = date_changed
    }
}

/// A full list with its items
public struct UserListDetail: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let description: String?
    public let resource_url: String
    public let uri: String?
    public let `public`: Bool?
    public let date_added: String?
    public let date_changed: String?
    public let items: [UserListItem]

    public init(
        id: Int,
        name: String,
        description: String? = nil,
        resource_url: String,
        uri: String? = nil,
        public isPublic: Bool? = nil,
        date_added: String? = nil,
        date_changed: String? = nil,
        items: [UserListItem]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.resource_url = resource_url
        self.uri = uri
        self.`public` = isPublic
        self.date_added = date_added
        self.date_changed = date_changed
        self.items = items
    }
}

/// A single item within a user list
public struct UserListItem: Codable, Sendable, Identifiable {
    public let id: Int
    public let type: String  // "release", "master", "artist", "label"
    public let display_title: String?
    public let comment: String?
    public let uri: String?
    public let resource_url: String
    public let image_url: String?

    public init(
        id: Int,
        type: String,
        display_title: String? = nil,
        comment: String? = nil,
        uri: String? = nil,
        resource_url: String,
        image_url: String? = nil
    ) {
        self.id = id
        self.type = type
        self.display_title = display_title
        self.comment = comment
        self.uri = uri
        self.resource_url = resource_url
        self.image_url = image_url
    }
}
