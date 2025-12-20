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
    let userCache: Cache<UserIdentity>
    
    init(client: AsyncNetworkClientProtocol, userCache: Cache<UserIdentity>) {
        self.client = client
        self.userCache = userCache
    }
    
    public func collectionFolders() async throws -> CollectionFolders {
        let username = try await userCache.get().username
        let config = RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: username).url)
        let response: NetworkResponse<CollectionFolders> = try await client.request(for: config, with: JSONDecoder())
        guard let collectionFolders = response.data else { throw NetworkError.noData }
        return collectionFolders
    }
    
    public func folderPath() -> String {
        DiscogsEndpoint.collectionFolders().url.relativePath
    }
    
    public func folderRequest() async throws -> RequestConfiguration {
        let username = try await userCache.get().username
        return RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: username).url)
    }
    
    public func response(for requestConfiguration: RequestConfiguration) async throws -> NetworkResponse<Data> {
        try await client.requestRawData(for: requestConfiguration)
    }

    public func collectionItemsByRelease(
        releaseId: Int,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> CollectionReleasesResponse {
        let username = try await userCache.get().username
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByRelease(
                username: username,
                releaseId: releaseId,
                page: page,
                perPage: perPage
            ).url
        )
        let response: NetworkResponse<CollectionReleasesResponse> = try await client.request(for: config, with: JSONDecoder())
        guard let releases = response.data else { throw NetworkError.noData }
        return releases
    }
    
    public func collectionItemsByFolder(
        folderId: Int,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: DiscogsEndpoint.SortParameterValue? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil
    ) async throws -> CollectionReleasesResponse {
        let username = try await userCache.get().username
        let config = RequestConfiguration(
            url: DiscogsEndpoint.collectionItemsByFolder(
                username: username,
                folderId: folderId,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        let response: NetworkResponse<CollectionReleasesResponse> = try await client.request(for: config, with: JSONDecoder())
        guard let releases = response.data else { throw NetworkError.noData }
        return releases
    }
}
