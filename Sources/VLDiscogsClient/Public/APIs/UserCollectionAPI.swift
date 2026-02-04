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
    
    public func collectionFolders() async throws -> CollectionFolders {
        let config = RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: accountIdentifier).url)
        let response: NetworkResponse<CollectionFolders> = try await client.request(for: config, with: JSONDecoder())
        guard let collectionFolders = response.data else { throw NetworkError.noData }
        return collectionFolders
    }
    
    public func folderPath() -> String {
        DiscogsEndpoint.collectionFolders().url.relativePath
    }
    
    public func folderRequest() async throws -> RequestConfiguration {
        return RequestConfiguration(url: DiscogsEndpoint.collectionFolders(username: accountIdentifier).url)
    }
    
    public func response(for requestConfiguration: RequestConfiguration) async throws -> NetworkResponse<Data> {
        try await client.requestRawData(for: requestConfiguration)
    }

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
        let response: NetworkResponse<CollectionReleasesResponse> = try await client.request(for: config, with: JSONDecoder())
        guard let releases = response.data else { throw NetworkError.noData }
        return releases
    }
}
