//
//  InventoryUploadAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/27/26.
//

import Foundation
import VLNetworkingClient

public struct InventoryUploadAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Uploads

    /// Get a list of recent inventory uploads for the authenticated user
    public func recentUploads(page: Int? = nil, perPage: Int? = nil) async throws -> InventoryUploadsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.inventoryUploads(page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(InventoryUploadsResponse.self)
    }

    /// Upload a CSV inventory file
    ///
    /// - Parameters:
    ///   - type: Whether to add, change, or delete listings.
    ///   - csvData: The raw CSV content.
    ///   - filename: The filename reported in the multipart upload. Defaults to `"inventory.csv"`.
    @discardableResult
    public func upload(
        type: DiscogsEndpoint.InventoryUploadType,
        csvData: Data,
        filename: String = "inventory.csv"
    ) async throws -> InventoryUpload {
        let boundary = "Boundary-\(UUID().uuidString)"
        var headers = RequestConfiguration.defaultHeaders
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        let config = RequestConfiguration(
            url: DiscogsEndpoint.inventoryUploadByType(type: type).url,
            method: .POST,
            headers: headers,
            body: multipartBody(csvData: csvData, filename: filename, boundary: boundary)
        )
        return try await client.request(for: config).decode(InventoryUpload.self)
    }

    /// Upload a CSV inventory file from a local file URL
    ///
    /// - Parameters:
    ///   - type: Whether to add, change, or delete listings.
    ///   - fileURL: Local URL of the CSV file to upload.
    @discardableResult
    public func upload(
        type: DiscogsEndpoint.InventoryUploadType,
        fileURL: URL
    ) async throws -> InventoryUpload {
        let csvData = try Data(contentsOf: fileURL)
        return try await upload(type: type, csvData: csvData, filename: fileURL.lastPathComponent)
    }

    /// Get a specific inventory upload by ID
    public func upload(id: Int) async throws -> InventoryUpload {
        let config = RequestConfiguration(url: DiscogsEndpoint.inventoryUploadById(id: id).url)
        return try await client.request(for: config).decode(InventoryUpload.self)
    }

    // MARK: - Private

    private func multipartBody(csvData: Data, filename: String, boundary: String) -> Data {
        var body = Data()
        func append(_ string: String) { body.append(Data(string.utf8)) }
        append("--\(boundary)\r\n")
        append("Content-Disposition: form-data; name=\"upload\"; filename=\"\(filename)\"\r\n")
        append("Content-Type: text/csv\r\n")
        append("\r\n")
        body.append(csvData)
        append("\r\n")
        append("--\(boundary)--\r\n")
        return body
    }
}

// MARK: - Response Models

/// Processing results for a completed inventory upload
public struct UploadResults: Codable, Sendable {
    public let submitted: Int?
    public let processed: Int?
    public let skipped: Int?
    public let errors: Int?

    public init(
        submitted: Int? = nil,
        processed: Int? = nil,
        skipped: Int? = nil,
        errors: Int? = nil
    ) {
        self.submitted = submitted
        self.processed = processed
        self.skipped = skipped
        self.errors = errors
    }
}

/// A single inventory upload record
public struct InventoryUpload: Codable, Sendable, Identifiable {
    public let id: Int
    public let status: String  // "queued", "in_progress", "done", "error"
    public let created_ts: String?
    public let filename: String?
    public let type: String?   // "add", "change", "delete"
    public let error_message: String?
    public let results: UploadResults?
    public let url: String?
    public let resource_url: String?

    public init(
        id: Int,
        status: String,
        created_ts: String? = nil,
        filename: String? = nil,
        type: String? = nil,
        error_message: String? = nil,
        results: UploadResults? = nil,
        url: String? = nil,
        resource_url: String? = nil
    ) {
        self.id = id
        self.status = status
        self.created_ts = created_ts
        self.filename = filename
        self.type = type
        self.error_message = error_message
        self.results = results
        self.url = url
        self.resource_url = resource_url
    }
}

/// Paginated list of inventory uploads
public struct InventoryUploadsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let items: [InventoryUpload]

    public init(pagination: Pagination, items: [InventoryUpload]) {
        self.pagination = pagination
        self.items = items
    }
}
