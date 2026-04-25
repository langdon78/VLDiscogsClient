//
//  UserIdentityAPITests.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 3/4/26.
//

import Testing
import Foundation
@testable import VLDiscogsClient
@testable import VLNetworkingClient

// MARK: - Test Suite

@Suite("UserIdentityAPI Tests")
struct UserIdentityAPITests {
    
    // MARK: - Identity Tests
    
    @Test("Get identity returns authenticated user info")
    func testGetIdentity() async throws {
        let mockClient = MockNetworkClient()
        let expectedIdentity = DiscogsIdentity(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            consumer_name: "TestApp"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedIdentity
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getIdentity()
        
        #expect(result.id == 12345)
        #expect(result.username == "testuser")
        #expect(result.consumer_name == "TestApp")
        #expect(result.resource_url == "https://api.discogs.com/users/testuser")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    // MARK: - Profile Tests
    
    @Test("Get profile returns user details")
    func testGetProfile() async throws {
        let mockClient = MockNetworkClient()
        let expectedUser = DiscogsUser(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            uri: "https://www.discogs.com/user/testuser",
            name: "Test User",
            home_page: "https://example.com",
            location: "San Francisco, CA",
            profile: "I love vinyl!",
            registered: "2020-01-01T00:00:00-00:00",
            num_collection: 250,
            num_wantlist: 50,
            num_lists: 5,
            releases_contributed: 10,
            releases_rated: 100,
            rating_avg: 4.5,
            curr_abbr: "USD"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedUser
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getProfile(username: "testuser")
        
        #expect(result.id == 12345)
        #expect(result.username == "testuser")
        #expect(result.name == "Test User")
        #expect(result.location == "San Francisco, CA")
        #expect(result.num_collection == 250)
        #expect(result.num_wantlist == 50)
        #expect(result.rating_avg == 4.5)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
        #expect(config?.url.absoluteString.contains("testuser") == true)
    }
    
    @Test("Edit profile updates user information")
    func testEditProfile() async throws {
        let mockClient = MockNetworkClient()
        let updatedUser = DiscogsUser(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            uri: "https://www.discogs.com/user/testuser",
            name: "Updated Name",
            home_page: "https://newsite.com",
            location: "New York, NY",
            profile: "New profile text"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return updatedUser
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.editProfile(
            username: "testuser",
            name: "Updated Name",
            homePage: "https://newsite.com",
            location: "New York, NY",
            profile: "New profile text"
        )
        
        #expect(result.name == "Updated Name")
        #expect(result.home_page == "https://newsite.com")
        #expect(result.location == "New York, NY")
        #expect(result.profile == "New profile text")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
        
        // Verify the body contains the profile fields
        if let body = config?.body,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            #expect(json["name"] as? String == "Updated Name")
            #expect(json["home_page"] as? String == "https://newsite.com")
            #expect(json["location"] as? String == "New York, NY")
            #expect(json["profile"] as? String == "New profile text")
        }
    }
    
    @Test("Edit profile with partial updates")
    func testEditProfilePartial() async throws {
        let mockClient = MockNetworkClient()
        let updatedUser = DiscogsUser(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            uri: "https://www.discogs.com/user/testuser",
            name: "Just Name Updated"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return updatedUser
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.editProfile(
            username: "testuser",
            name: "Just Name Updated"
        )
        
        #expect(result.name == "Just Name Updated")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .POST)
        #expect(config?.body != nil)
        
        // Verify only name is in the body
        if let body = config?.body,
           let json = try? JSONSerialization.jsonObject(with: body) as? [String: Any] {
            #expect(json.count == 1)
            #expect(json["name"] as? String == "Just Name Updated")
        }
    }
    
    // MARK: - Submissions Tests
    
    @Test("Get submissions returns user's contributions")
    func testGetSubmissions() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = UserSubmissionsResponse(
            pagination: Pagination(
                page: 1,
                pages: 1,
                per_page: 50,
                items: 3,
                urls: PaginationUrls(last: nil, next: nil)
            ),
            submissions: UserSubmissions(
                releases: [
                    UserSubmissionItem(
                        id: 1,
                        title: "Test Release",
                        resource_url: "https://api.discogs.com/releases/1",
                        year: 2020
                    )
                ],
                labels: [
                    UserSubmissionItem(
                        id: 2,
                        name: "Test Label",
                        resource_url: "https://api.discogs.com/labels/2"
                    )
                ],
                artists: [
                    UserSubmissionItem(
                        id: 3,
                        name: "Test Artist",
                        resource_url: "https://api.discogs.com/artists/3"
                    )
                ]
            )
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getSubmissions(
            username: "testuser",
            page: 1,
            perPage: 50
        )
        
        #expect(result.pagination.items == 3)
        #expect(result.submissions.releases?.count == 1)
        #expect(result.submissions.labels?.count == 1)
        #expect(result.submissions.artists?.count == 1)
        #expect(result.submissions.releases?.first?.title == "Test Release")
        #expect(result.submissions.labels?.first?.name == "Test Label")
        #expect(result.submissions.artists?.first?.name == "Test Artist")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    @Test("Get submissions with pagination")
    func testGetSubmissionsWithPagination() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = UserSubmissionsResponse(
            pagination: Pagination(
                page: 2,
                pages: 5,
                per_page: 25,
                items: 100,
                urls: PaginationUrls(
                    last: "https://api.discogs.com/users/testuser/submissions?page=5",
                    next: "https://api.discogs.com/users/testuser/submissions?page=3"
                )
            ),
            submissions: UserSubmissions(releases: [])
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getSubmissions(
            username: "testuser",
            page: 2,
            perPage: 25
        )
        
        #expect(result.pagination.page == 2)
        #expect(result.pagination.pages == 5)
        #expect(result.pagination.items == 100)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    // MARK: - Contributions Tests
    
    @Test("Get contributions returns user's edits")
    func testGetContributions() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = UserContributionsResponse(
            pagination: Pagination(
                page: 1,
                pages: 1,
                per_page: 50,
                items: 2,
                urls: PaginationUrls(last: nil, next: nil)
            ),
            contributions: [
                UserContribution(
                    id: 1,
                    title: "Contributed Release",
                    resource_url: "https://api.discogs.com/releases/1",
                    year: 2021,
                    type: "release"
                ),
                UserContribution(
                    id: 2,
                    name: "Contributed Artist",
                    resource_url: "https://api.discogs.com/artists/2",
                    type: "artist"
                )
            ]
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getContributions(username: "testuser")
        
        #expect(result.pagination.items == 2)
        #expect(result.contributions.count == 2)
        #expect(result.contributions[0].title == "Contributed Release")
        #expect(result.contributions[0].type == "release")
        #expect(result.contributions[1].name == "Contributed Artist")
        #expect(result.contributions[1].type == "artist")
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
    
    @Test("Get contributions with sort parameters")
    func testGetContributionsWithSort() async throws {
        let mockClient = MockNetworkClient()
        let expectedResponse = UserContributionsResponse(
            pagination: Pagination(
                page: 1,
                pages: 1,
                per_page: 50,
                items: 0,
                urls: PaginationUrls(last: nil, next: nil)
            ),
            contributions: []
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return expectedResponse
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let result = try await api.getContributions(
            username: "testuser",
            page: 1,
            perPage: 50,
            sort: "year",
            sortOrder: "desc"
        )
        
        #expect(result.contributions.count == 0)
        
        let config = await mockClient.getLastConfiguration()
        #expect(config?.method == .GET)
    }
}

// MARK: - Error Handling Tests

@Suite("UserIdentityAPI Error Handling")
struct UserIdentityAPIErrorTests {
    
    @Test("Handles network errors gracefully")
    func testNetworkError() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            throw NetworkError.noData
        }
        
        let api = UserIdentityAPI(client: mockClient)
        
        await #expect(throws: NetworkError.self) {
            try await api.getIdentity()
        }
    }
    
    @Test("Handles missing data in profile response")
    func testMissingDataInProfile() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return Optional<DiscogsUser>.none as Any
        }
        
        let api = UserIdentityAPI(client: mockClient)
        
        await #expect(throws: NetworkError.self) {
            try await api.getProfile(username: "testuser")
        }
    }
    
    @Test("Handles invalid username")
    func testInvalidUsername() async throws {
        let mockClient = MockNetworkClient()
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            throw NetworkError.notFound
        }
        
        let api = UserIdentityAPI(client: mockClient)
        
        await #expect(throws: NetworkError.self) {
            try await api.getProfile(username: "nonexistent")
        }
    }
}

// MARK: - Response Model Tests

@Suite("UserIdentity Response Models")
struct UserIdentityResponseModelTests {
    
    @Test("DiscogsIdentity encodes and decodes")
    func testDiscogsIdentityCoding() throws {
        let identity = DiscogsIdentity(
            id: 123,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            consumer_name: "TestApp"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(identity)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiscogsIdentity.self, from: data)
        
        #expect(decoded.id == 123)
        #expect(decoded.username == "testuser")
        #expect(decoded.consumer_name == "TestApp")
    }
    
    @Test("DiscogsUser with all fields encodes and decodes")
    func testDiscogsUserFullCoding() throws {
        let user = DiscogsUser(
            id: 456,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            uri: "https://www.discogs.com/user/testuser",
            name: "Test User",
            home_page: "https://example.com",
            location: "San Francisco",
            profile: "Profile text",
            registered: "2020-01-01",
            num_collection: 100,
            num_wantlist: 50,
            curr_abbr: "USD"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(user)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiscogsUser.self, from: data)
        
        #expect(decoded.id == 456)
        #expect(decoded.username == "testuser")
        #expect(decoded.name == "Test User")
        #expect(decoded.num_collection == 100)
    }
    
    @Test("DiscogsUser with minimal fields")
    func testDiscogsUserMinimal() throws {
        let user = DiscogsUser(
            id: 789,
            username: "minimaluser",
            resource_url: "https://api.discogs.com/users/minimaluser",
            uri: "https://www.discogs.com/user/minimaluser"
        )
        
        #expect(user.id == 789)
        #expect(user.username == "minimaluser")
        #expect(user.name == nil)
        #expect(user.location == nil)
    }
    
    @Test("UserSubmissionItem encodes and decodes")
    func testUserSubmissionItemCoding() throws {
        let item = UserSubmissionItem(
            id: 1,
            title: "Test Release",
            resource_url: "https://api.discogs.com/releases/1",
            year: 2020
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(item)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserSubmissionItem.self, from: data)
        
        #expect(decoded.id == 1)
        #expect(decoded.title == "Test Release")
        #expect(decoded.year == 2020)
    }
    
    @Test("UserContribution encodes and decodes")
    func testUserContributionCoding() throws {
        let contribution = UserContribution(
            id: 2,
            title: "Test Contribution",
            resource_url: "https://api.discogs.com/releases/2",
            year: 2021,
            type: "release"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(contribution)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(UserContribution.self, from: data)
        
        #expect(decoded.id == 2)
        #expect(decoded.title == "Test Contribution")
        #expect(decoded.type == "release")
    }
    
    @Test("UserSubmissions handles optional arrays")
    func testUserSubmissionsOptionals() throws {
        let submissionsWithReleases = UserSubmissions(
            releases: [
                UserSubmissionItem(
                    id: 1,
                    title: "Release",
                    resource_url: "https://api.discogs.com/releases/1"
                )
            ],
            labels: nil,
            artists: nil
        )
        
        #expect(submissionsWithReleases.releases?.count == 1)
        #expect(submissionsWithReleases.labels == nil)
        #expect(submissionsWithReleases.artists == nil)
        
        let emptySubmissions = UserSubmissions()
        #expect(emptySubmissions.releases == nil)
        #expect(emptySubmissions.labels == nil)
        #expect(emptySubmissions.artists == nil)
    }
}

// MARK: - Integration-Style Tests

@Suite("UserIdentityAPI Integration Tests")
struct UserIdentityAPIIntegrationTests {
    
    @Test("Complete user workflow - get identity then profile")
    func testCompleteUserWorkflow() async throws {
        let mockClient = MockNetworkClient()
        
        // First get identity
        let identity = DiscogsIdentity(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            consumer_name: "TestApp"
        )
        
        await mockClient.reset()
        await mockClient.setRequestHandler { config in
            return identity
        }
        
        let api = UserIdentityAPI(client: mockClient)
        let identityResult = try await api.getIdentity()
        
        #expect(identityResult.username == "testuser")
        
        // Then get full profile using the username
        let user = DiscogsUser(
            id: 12345,
            username: "testuser",
            resource_url: "https://api.discogs.com/users/testuser",
            uri: "https://www.discogs.com/user/testuser",
            num_collection: 100
        )
        
        await mockClient.setRequestHandler { config in
            return user
        }
        
        let profileResult = try await api.getProfile(username: identityResult.username)
        
        #expect(profileResult.id == identityResult.id)
        #expect(profileResult.username == identityResult.username)
        #expect(profileResult.num_collection == 100)
    }
}
