//
//  InventoryExportAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/27/26.
//

import Foundation
import VLNetworkingClient

public struct InventoryExportAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Exports

    /// Request a new inventory export for the authenticated user
    @discardableResult
    public func requestExport() async throws -> InventoryExport {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.inventoryExports().url,
            method: .POST
        )
        return try await client.request(for: config).decode(InventoryExport.self)
    }

    /// Get a list of recent inventory exports for the authenticated user
    public func recentExports(page: Int? = nil, perPage: Int? = nil) async throws -> InventoryExportsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.inventoryExports(page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(InventoryExportsResponse.self)
    }

    /// Get a specific inventory export by ID
    public func export(id: Int) async throws -> InventoryExport {
        let config = RequestConfiguration(url: DiscogsEndpoint.inventoryExport(id: id).url)
        return try await client.request(for: config).decode(InventoryExport.self)
    }

    /// Download an export as raw CSV data
    public func downloadExport(id: Int) async throws -> Data {
        let config = RequestConfiguration(url: DiscogsEndpoint.inventoryExportDownload(id: id).url)
        let response = try await client.request(for: config)
        guard let data = response.data else { throw NetworkError.noData }
        return data
    }

    /// Download an export and save it directly to a file URL
    public func downloadExport(id: Int, to destination: URL) async throws -> URL {
        let config = RequestConfiguration(url: DiscogsEndpoint.inventoryExportDownload(id: id).url)
        return try await client.downloadFile(config, to: destination)
    }
}

// MARK: - Response Models

/// The status of an inventory export job
public enum ExportStatus: String, Codable, Sendable {
    case finished = "Finished"
    case inProgress = "in_progress"
    case failed = "Failed"
}

/// A single inventory export record
public struct InventoryExport: Codable, Sendable, Identifiable {
    public let id: Int
    public let status: String
    public let created_ts: String?
    public let url: String?
    public let filename: String?
    public let download_url: String?

    public var exportStatus: ExportStatus? { ExportStatus(rawValue: status) }

    public init(
        id: Int,
        status: String,
        created_ts: String? = nil,
        url: String? = nil,
        filename: String? = nil,
        download_url: String? = nil
    ) {
        self.id = id
        self.status = status
        self.created_ts = created_ts
        self.url = url
        self.filename = filename
        self.download_url = download_url
    }
}

/// Paginated list of inventory exports
public struct InventoryExportsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let items: [InventoryExport]

    public init(pagination: Pagination, items: [InventoryExport]) {
        self.pagination = pagination
        self.items = items
    }
}
