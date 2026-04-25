//
//  UserCollectionAPITests.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 3/4/26.
//

import Testing
import Foundation
@testable import VLDiscogsClient
@testable import VLNetworkingClient

// MARK: - Mock Network Client

/// Mock network client for testing API calls
actor MockNetworkClient: AsyncNetworkClientProtocol {
    var requestHandler: ((RequestConfiguration) async throws -> Any)?
    var capturedConfigurations: [RequestConfiguration] = []
    
    func request<T: Codable & Sendable>(
        for config: RequestConfiguration,
        with decoder: ResponseBodyDecoder
    ) async throws -> NetworkResponse<T> {
        capturedConfigurations.append(config)
        
        guard let handler = requestHandler else {
            throw NetworkError.noData
        }
        
        let result = try await handler(config)
        
        // Create a mock HTTP response
        let httpResponse = HTTPURLResponse(
            url: config.url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        
        if let data = result as? T {
            return NetworkResponse(data: data, response: httpResponse)
        } else {
            return NetworkResponse(data: nil, response: httpResponse)
        }
    }
    
    func requestRawData(
        for config: RequestConfiguration
    ) async throws -> NetworkResponse<Data> {
        capturedConfigurations.append(config)
        
        let httpResponse = HTTPURLResponse(
            url: config.url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        
        let data = Data()
        return NetworkResponse(data: data, response: httpResponse)
    }
    
    func downloadFile(
        _ config: RequestConfiguration,
        to destination: URL
    ) async throws -> NetworkResponse<URL> {
        capturedConfigurations.append(config)
        
        let httpResponse = HTTPURLResponse(
            url: config.url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        
        return NetworkResponse(data: destination, response: httpResponse)
    }
    
    func uploadFile(
        _ config: RequestConfiguration,
        from fileURL: URL
    ) async throws -> NetworkResponse<Data> {
        capturedConfigurations.append(config)
        
        let httpResponse = HTTPURLResponse(
            url: config.url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
        
        return NetworkResponse(data: Data(), response: httpResponse)
    }
    
    func reset() {
        capturedConfigurations.removeAll()
        requestHandler = nil
    }
    
    func setRequestHandler(_ handler: @escaping (RequestConfiguration) async throws -> Any) {
        requestHandler = handler
    }
    
    func getLastConfiguration() -> RequestConfiguration? {
        capturedConfigurations.last
    }
}

// MARK: - Test Suite

@Suite("UserCollectionAPI Tests")
struct UserCollectionAPITests {
    
    // MARK: - Folder Tests
    
    @Test("Get collection folders returns folders")
    func testGetCollectionFolders() async throws {
        let mockClient = MockNetworkClient()
        let expectedFolders = CollectionFolders(folders: [
            CollectionFolder(id: 0, count: 100, name: "All", resource_url: "https://api.discogs.com/users/testuser/collection/folders/0"),
            CollectionFolder(id: 1, count: 50, name: "Uncategorized", resource_url: "https://api.discogs.com/users/testuser/collection/folders/1")
        ])
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedFolders
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.collectionFolders()
        
        #expect(result.folders.count == 2)
        #expect(result.folders[0].name == "All")
        #expect(result.folders[1].name == "Uncategorized")
        
        // Verify request configuration
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
        #expect(config?.url.absoluteString.contains("testuser") == true)
    }
    
    @Test("Get specific folder by ID")
    func testGetCollectionFolder() async throws {
        let mockClient = MockNetworkClient()
        let expectedFolder = CollectionFolder(
            id: 1,
            count: 25,
            name: "My Favorites",
            resource_url: "https://api.discogs.com/users/testuser/collection/folders/1"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedFolder
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.collectionFolder(folderId: 1)
        
        #expect(result.id == 1)
        #expect(result.name == "My Favorites")
        #expect(result.count == 25)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
        #expect(config?.url.absoluteString.contains("folders/1") == true)
    }
    
    @Test("Create folder with name")
    func testCreateFolder() async throws {
        let mockClient = MockNetworkClient()
        let expectedFolder = CollectionFolder(
            id: 2,
            count: 0,
            name: "New Folder",
            resource_url: "https://api.discogs.com/users/testuser/collection/folders/2"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedFolder
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.createFolder(name: "New Folder")
        
        #expect(result.name == "New Folder")
        #expect(result.count == 0)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
    }
    
    @Test("Update folder name")
    func testUpdateFolder() async throws {
        let mockClient = MockNetworkClient()
        let updatedFolder = CollectionFolder(
            id: 1,
            count: 25,
            name: "Updated Name",
            resource_url: "https://api.discogs.com/users/testuser/collection/folders/1"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return updatedFolder
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.updateFolder(folderId: 1, name: "Updated Name")
        
        #expect(result.name == "Updated Name")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
        #expect(config?.url.absoluteString.contains("folders/1") == true)
    }
    
    @Test("Delete folder")
    func testDeleteFolder() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return EmptyResponse()
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        try await api.deleteFolder(folderId: 1)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .DELETE)
        #expect(config?.url.absoluteString.contains("folders/1") == true)
    }
    
    // MARK: - Collection Item Tests
    
    @Test("Get collection items by release ID")
    func testCollectionItemsByRelease() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = CollectionReleasesResponse(
            pagination: Pagination(page: 1, pages: 1, per_page: 50, items: 1, urls: PaginationUrls(last: nil, next: nil)),
            releases: []
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.collectionItemsByRelease(
            releaseId: 12345,
            page: 1,
            perPage: 50
        )
        
        #expect(result.pagination.page == 1)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
        #expect(config?.url.absoluteString.contains("12345") == true)
    }
    
    @Test("Get collection items by folder")
    func testCollectionItemsByFolder() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = CollectionReleasesResponse(
            pagination: Pagination(page: 1, pages: 2, per_page: 50, items: 75, urls: PaginationUrls(last: nil, next: nil)),
            releases: []
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.collectionItemsByFolder(
            folderId: 1,
            page: 1,
            perPage: 50
        )
        
        #expect(result.pagination.items == 75)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    @Test("Add release to folder")
    func testAddReleaseToFolder() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = AddToCollectionResponse(
            instance_id: 999,
            resource_url: "https://api.discogs.com/users/testuser/collection/folders/1/releases/12345/instances/999"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.addReleaseToFolder(releaseId: 12345, folderId: 1)
        
        #expect(result.instance_id == 999)
        #expect(result.resource_url.contains("instances/999"))
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
    }
    
    @Test("Change rating of release instance")
    func testChangeRating() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return EmptyResponse()
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        try await api.changeRating(
            folderId: 1,
            releaseId: 12345,
            instanceId: 999,
            rating: 5
        )
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
        
        // Verify the body contains the rating
        if let body = config?.body,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            #expect(json["rating"] as? Int == 5)
        }
    }
    
    @Test("Delete release instance")
    func testDeleteReleaseInstance() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return EmptyResponse()
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        try await api.deleteReleaseInstance(
            folderId: 1,
            releaseId: 12345,
            instanceId: 999
        )
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .DELETE)
        #expect(config?.url.absoluteString.contains("instances/999") == true)
    }
    
    // MARK: - Custom Fields Tests
    
    @Test("Get custom fields")
    func testGetCustomFields() async throws {
        let mockClient = MockNetworkClient()
        let expectedFields = CustomFieldsResponse(fields: [
            CustomField(
                id: 1,
                name: "Condition",
                options: ["Mint", "Near Mint", "Good"],
                type: "dropdown",
                position: 1,
                public: true
            ),
            CustomField(
                id: 2,
                name: "Notes",
                options: nil,
                type: "textarea",
                position: 2,
                public: false
            )
        ])
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedFields
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.customFields()
        
        #expect(result.fields.count == 2)
        #expect(result.fields[0].name == "Condition")
        #expect(result.fields[0].type == "dropdown")
        #expect(result.fields[0].`public` == true)
        #expect(result.fields[1].name == "Notes")
        #expect(result.fields[1].type == "textarea")
        #expect(result.fields[1].`public` == false)
    }
    
    @Test("Edit instance field")
    func testEditInstanceField() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return EmptyResponse()
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        try await api.editInstanceField(
            folderId: 1,
            releaseId: 12345,
            instanceId: 999,
            fieldId: 1,
            value: "Mint"
        )
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
        
        // Verify the body contains the field value
        if let body = config?.body,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            #expect(json["value"] as? String == "Mint")
            #expect(json["field_id"] as? Int == 1)
        }
    }
    
    // MARK: - Collection Value Tests
    
    @Test("Get collection value")
    func testGetCollectionValue() async throws {
        let mockClient = MockNetworkClient()
        let expectedValue = CollectionValue(
            minimum: "€1,234.56",
            median: "€2,345.67",
            maximum: "€3,456.78"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedValue
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        let result = try await api.collectionValue()
        
        #expect(result.minimum == "€1,234.56")
        #expect(result.median == "€2,345.67")
        #expect(result.maximum == "€3,456.78")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    // MARK: - Utility Methods Tests
    
    @Test("Folder path returns correct path")
    func testFolderPath() async throws {
        let mockClient = MockNetworkClient()
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        
        let path = api.folderPath()
        #expect(path.contains("collection"))
    }
    
    @Test("Folder request creates valid configuration")
    func testFolderRequest() async throws {
        let mockClient = MockNetworkClient()
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        
        let config = try await api.folderRequest()
        #expect(config.url.absoluteString.contains("testuser"))
        #expect(config.method == .GET)
    }
    
    @Test("Response method returns network response")
    func testResponse() async throws {
        let mockClient = MockNetworkClient()
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        
        let testConfig = RequestConfiguration(
            url: URL(string: "https://api.discogs.com/test")!
        )
        
        let response = try await api.response(for: testConfig)
        #expect(response.statusCode == 200)
    }
}

// MARK: - Error Handling Tests

@Suite("UserCollectionAPI Error Handling")
struct UserCollectionAPIErrorTests {
    
    @Test("Handles network errors gracefully")
    func testNetworkError() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            throw NetworkError.noData
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        
        await #expect(throws: NetworkError.self) {
            try await api.collectionFolders()
        }
    }
    
    @Test("Handles missing data in response")
    func testMissingData() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return Optional<CollectionFolders>.none as Any
        }
        
        let api = UserCollectionAPI(client: mockClient, accountIdentifier: "testuser")
        
        await #expect(throws: NetworkError.self) {
            try await api.collectionFolders()
        }
    }
}

// MARK: - Response Model Tests

@Suite("Response Models")
struct ResponseModelTests {
    
    @Test("AddToCollectionResponse encodes and decodes")
    func testAddToCollectionResponseCoding() throws {
        let response = AddToCollectionResponse(
            instance_id: 123,
            resource_url: "https://api.discogs.com/test"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AddToCollectionResponse.self, from: data)
        
        #expect(decoded.instance_id == 123)
        #expect(decoded.resource_url == "https://api.discogs.com/test")
    }
    
    @Test("CustomField handles public keyword correctly")
    func testCustomFieldPublicProperty() throws {
        let field = CustomField(
            id: 1,
            name: "Test",
            type: "dropdown",
            position: 1,
            public: true
        )
        
        #expect(field.`public` == true)
        
        // Test encoding/decoding
        let encoder = JSONEncoder()
        let data = try encoder.encode(field)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CustomField.self, from: data)
        
        #expect(decoded.`public` == true)
    }
    
    @Test("CollectionValue formats currency strings")
    func testCollectionValue() throws {
        let value = CollectionValue(
            minimum: "$100.00",
            median: "$500.00",
            maximum: "$1,000.00"
        )
        
        #expect(value.minimum == "$100.00")
        #expect(value.median == "$500.00")
        #expect(value.maximum == "$1,000.00")
    }
    
    @Test("EmptyResponse initializes correctly")
    func testEmptyResponse() throws {
        let response = EmptyResponse()
        
        // Test that it can be encoded/decoded
        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(EmptyResponse.self, from: data)
        
        // EmptyResponse has no properties to verify, just ensure it works
        #expect(decoded != nil)
    }
}
