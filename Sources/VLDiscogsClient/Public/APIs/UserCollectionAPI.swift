//
//  UserCollectionAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 12/10/25.
//

import Foundation
import VLNetworkingClient

public struct UserCollectionAPI: Sendable {
    let client: AsyncNetworkClientProtocol
    let accountIdentifier: String

    init(client: AsyncNetworkClientProtocol, accountIdentifier: String) {
        self.client = client
        self.accountIdentifier = accountIdentifier
    }

    // MARK: - Folders

    /// Get all folders in the user's collection
    public func collectionFolders() async throws -> CollectionFolders {
        let config = RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: accountIdentifier).url)
        return try await client.request(for: config).decode(CollectionFolders.self)
    }

    /// Get a specific folder by ID
    public func collectionFolder(folderId: Int) async throws -> CollectionFolder {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionFolder(username: accountIdentifier, folderId: folderId).url
        )
        return try await client.request(for: config).decode(CollectionFolder.self)
    }

    /// Create a new folder in the collection
    public func createFolder(name: String) async throws -> CollectionFolder {
        let bodyData = try JSONSerialization.data(withJSONObject: ["name": name])
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionFolders(username: accountIdentifier).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(CollectionFolder.self)
    }

    /// Update a folder's name
    public func updateFolder(folderId: Int, name: String) async throws -> CollectionFolder {
        let bodyData = try JSONSerialization.data(withJSONObject: ["name": name])
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionFolder(username: accountIdentifier, folderId: folderId).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(CollectionFolder.self)
    }

    /// Delete a folder (folder must be empty)
    public func deleteFolder(folderId: Int) async throws {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionFolder(username: accountIdentifier, folderId: folderId).url,
            method: .DELETE
        )
        _ = try await client.request(for: config)
    }

    // MARK: - Collection Items

    /// Get items in a collection by release ID
    public func collectionItemsByRelease(
        releaseId: Int,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> CollectionReleasesResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByRelease(
                username: accountIdentifier,
                releaseId: releaseId,
                page: page,
                perPage: perPage
            ).url
        )
        return try await client.request(for: config).decode(CollectionReleasesResponse.self)
    }

    /// Get items in a collection folder
    public func collectionItemsByFolder(
        folderId: Int,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: DiscogsEndpoint.SortParameterValue? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil
    ) async throws -> CollectionReleasesResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByFolder(
                username: accountIdentifier,
                folderId: folderId,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        return try await client.request(for: config).decode(CollectionReleasesResponse.self)
    }

    /// Add a release to the collection
    public func addReleaseToFolder(releaseId: Int, folderId: Int) async throws -> AddToCollectionResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.addReleaseToFolder(
                username: accountIdentifier,
                folderId: folderId,
                releaseId: releaseId
            ).url,
            method: .POST
        )
        return try await client.request(for: config).decode(AddToCollectionResponse.self)
    }

    /// Change the rating of a release instance
    public func changeRating(folderId: Int, releaseId: Int, instanceId: Int, rating: Int) async throws {
        let bodyData = try JSONSerialization.data(withJSONObject: ["rating": rating])
        let config = RequestConfiguration(
            url: DiscogsEndpoint.editReleaseInstance(
                username: accountIdentifier,
                folderId: folderId,
                releaseId: releaseId,
                instanceId: instanceId
            ).url,
            method: .POST,
            body: bodyData
        )
        _ = try await client.request(for: config)
    }

    /// Delete an instance of a release from a folder
    public func deleteReleaseInstance(folderId: Int, releaseId: Int, instanceId: Int) async throws {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.editReleaseInstance(
                username: accountIdentifier,
                folderId: folderId,
                releaseId: releaseId,
                instanceId: instanceId
            ).url,
            method: .DELETE
        )
        _ = try await client.request(for: config)
    }

    // MARK: - Custom Fields

    /// Get custom fields for the collection
    public func customFields() async throws -> CustomFieldsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionFields(username: accountIdentifier).url
        )
        return try await client.request(for: config).decode(CustomFieldsResponse.self)
    }

    /// Edit a release instance's custom field value
    public func editInstanceField(
        folderId: Int,
        releaseId: Int,
        instanceId: Int,
        fieldId: Int,
        value: String
    ) async throws {
        let bodyData = try JSONSerialization.data(withJSONObject: ["value": value, "field_id": fieldId])
        let config = RequestConfiguration(
            url: DiscogsEndpoint.editReleaseInstance(
                username: accountIdentifier,
                folderId: folderId,
                releaseId: releaseId,
                instanceId: instanceId
            ).url,
            method: .POST,
            body: bodyData
        )
        _ = try await client.request(for: config)
    }

    // MARK: - Collection Value

    /// Get the minimum, median, and maximum value of the user's collection
    public func collectionValue() async throws -> CollectionValue {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionValue(username: accountIdentifier).url
        )
        return try await client.request(for: config).decode(CollectionValue.self)
    }

}

// MARK: - Response Models

/// Response when adding a release to the collection
public struct AddToCollectionResponse: Codable, Sendable {
    public let instance_id: Int
    public let resource_url: String

    public init(instance_id: Int, resource_url: String) {
        self.instance_id = instance_id
        self.resource_url = resource_url
    }
}

/// Custom fields in a collection
public struct CustomFieldsResponse: Codable, Sendable {
    public let fields: [CustomField]

    public init(fields: [CustomField]) {
        self.fields = fields
    }
}

/// A custom field definition
public struct CustomField: Codable, Sendable, Identifiable {
    public let id: Int
    public let name: String
    public let options: [String]?
    public let type: String  // "dropdown" or "textarea"
    public let position: Int
    public let `public`: Bool

    public init(
        id: Int,
        name: String,
        options: [String]? = nil,
        type: String,
        position: Int,
        public isPublic: Bool
    ) {
        self.id = id
        self.name = name
        self.options = options
        self.type = type
        self.position = position
        self.`public` = isPublic
    }
}

/// Empty response for operations that don't return data
public struct EmptyResponse: Codable, Sendable {
    public init() {}
}

/// Collection value statistics
public struct CollectionValue: Codable, Sendable {
    public let minimum: String
    public let median: String
    public let maximum: String

    public init(minimum: String, median: String, maximum: String) {
        self.minimum = minimum
        self.median = median
        self.maximum = maximum
    }
}
