//
//  UserIdentityAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 3/4/26.
//

import Foundation
import VLNetworkingClient

/// API client for Discogs User Identity endpoints
public struct UserIdentityAPI: Sendable {
    let client: AsyncNetworkClientProtocol
    
    public init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }
    
    // MARK: - Identity
    
    /// Retrieve basic information about the authenticated user
    ///
    /// This endpoint returns information about the user associated with the OAuth token.
    /// You can use this information to display the user's details or username.
    ///
    /// - Returns: The authenticated user's identity
    /// - Throws: NetworkError if the request fails or data is missing
    public func getIdentity() async throws -> DiscogsIdentity {
        let config = RequestConfiguration(url: DiscogsEndpoint.identity.url)
        return try await client.request(for: config).decode(DiscogsIdentity.self)
    }
    
    // MARK: - Profile
    
    /// Get a user's profile by username
    ///
    /// - Parameter username: The username of the user whose profile you want to retrieve
    /// - Returns: The user's profile information
    /// - Throws: NetworkError if the request fails or data is missing
    public func getProfile(username: String) async throws -> DiscogsUser {
        let config = RequestConfiguration(url: DiscogsEndpoint.userProfile(username: username).url)
        return try await client.request(for: config).decode(DiscogsUser.self)
    }
    
    /// Edit a user's profile (authenticated user only)
    ///
    /// - Parameters:
    ///   - username: The username of the user (must be the authenticated user)
    ///   - name: The user's real name (optional)
    ///   - homePage: The user's website URL (optional)
    ///   - location: The user's location (optional)
    ///   - profile: The user's profile/bio text (optional)
    ///   - currAbbr: Currency abbreviation for marketplace listings (optional)
    /// - Returns: The updated user profile
    /// - Throws: NetworkError if the request fails or data is missing
    public func editProfile(
        username: String,
        name: String? = nil,
        homePage: String? = nil,
        location: String? = nil,
        profile: String? = nil,
        currAbbr: String? = nil
    ) async throws -> DiscogsUser {
        var params: [String: String] = [:]
        if let name = name { params["name"] = name }
        if let homePage = homePage { params["home_page"] = homePage }
        if let location = location { params["location"] = location }
        if let profile = profile { params["profile"] = profile }
        if let currAbbr = currAbbr { params["curr_abbr"] = currAbbr }

        let bodyData = try JSONSerialization.data(withJSONObject: params)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.userProfile(username: username).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(DiscogsUser.self)
    }
    
    // MARK: - User Submissions
    
    /// Get a user's submissions (releases, labels, artists they've added to Discogs)
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - page: The page number for pagination (optional)
    ///   - perPage: Number of items per page (optional, max 100)
    /// - Returns: Paginated list of user submissions
    /// - Throws: NetworkError if the request fails or data is missing
    public func getSubmissions(
        username: String,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> UserSubmissionsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.userSubmissions(username: username, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(UserSubmissionsResponse.self)
    }
    
    // MARK: - User Contributions
    
    /// Get a user's contributions (edits to existing releases, labels, artists)
    ///
    /// - Parameters:
    ///   - username: The username
    ///   - page: The page number for pagination (optional)
    ///   - perPage: Number of items per page (optional, max 100)
    ///   - sort: Sort field (optional)
    ///   - sortOrder: Sort order - asc or desc (optional)
    /// - Returns: Paginated list of user contributions
    /// - Throws: NetworkError if the request fails or data is missing
    public func getContributions(
        username: String,
        page: Int? = nil,
        perPage: Int? = nil,
        sort: String? = nil,
        sortOrder: String? = nil
    ) async throws -> UserContributionsResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.userContributions(
                username: username,
                page: page,
                perPage: perPage,
                sort: sort,
                sortOrder: sortOrder
            ).url
        )
        return try await client.request(for: config).decode(UserContributionsResponse.self)
    }
}

// MARK: - Response Models

/// The authenticated user's identity
public struct DiscogsIdentity: Codable, Sendable {
    public let id: Int
    public let username: String
    public let resource_url: String
    public let consumer_name: String
    
    public init(
        id: Int,
        username: String,
        resource_url: String,
        consumer_name: String
    ) {
        self.id = id
        self.username = username
        self.resource_url = resource_url
        self.consumer_name = consumer_name
    }
}

/// A Discogs user's profile
public struct DiscogsUser: Codable, Sendable {
    public let id: Int
    public let username: String
    public let resource_url: String
    public let uri: String
    public let name: String?
    public let home_page: String?
    public let location: String?
    public let profile: String?
    public let registered: String?
    public let num_collection: Int?
    public let num_wantlist: Int?
    public let num_lists: Int?
    public let num_for_sale: Int?
    public let num_pending: Int?
    public let releases_contributed: Int?
    public let releases_rated: Int?
    public let rating_avg: Double?
    public let inventory_url: String?
    public let collection_folders_url: String?
    public let collection_fields_url: String?
    public let wantlist_url: String?
    public let avatar_url: String?
    public let banner_url: String?
    public let buyer_rating: Double?
    public let buyer_rating_stars: Int?
    public let buyer_num_ratings: Int?
    public let seller_rating: Double?
    public let seller_rating_stars: Int?
    public let seller_num_ratings: Int?
    public let curr_abbr: String?
    
    public init(
        id: Int,
        username: String,
        resource_url: String,
        uri: String,
        name: String? = nil,
        home_page: String? = nil,
        location: String? = nil,
        profile: String? = nil,
        registered: String? = nil,
        num_collection: Int? = nil,
        num_wantlist: Int? = nil,
        num_lists: Int? = nil,
        num_for_sale: Int? = nil,
        num_pending: Int? = nil,
        releases_contributed: Int? = nil,
        releases_rated: Int? = nil,
        rating_avg: Double? = nil,
        inventory_url: String? = nil,
        collection_folders_url: String? = nil,
        collection_fields_url: String? = nil,
        wantlist_url: String? = nil,
        avatar_url: String? = nil,
        banner_url: String? = nil,
        buyer_rating: Double? = nil,
        buyer_rating_stars: Int? = nil,
        buyer_num_ratings: Int? = nil,
        seller_rating: Double? = nil,
        seller_rating_stars: Int? = nil,
        seller_num_ratings: Int? = nil,
        curr_abbr: String? = nil
    ) {
        self.id = id
        self.username = username
        self.resource_url = resource_url
        self.uri = uri
        self.name = name
        self.home_page = home_page
        self.location = location
        self.profile = profile
        self.registered = registered
        self.num_collection = num_collection
        self.num_wantlist = num_wantlist
        self.num_lists = num_lists
        self.num_for_sale = num_for_sale
        self.num_pending = num_pending
        self.releases_contributed = releases_contributed
        self.releases_rated = releases_rated
        self.rating_avg = rating_avg
        self.inventory_url = inventory_url
        self.collection_folders_url = collection_folders_url
        self.collection_fields_url = collection_fields_url
        self.wantlist_url = wantlist_url
        self.avatar_url = avatar_url
        self.banner_url = banner_url
        self.buyer_rating = buyer_rating
        self.buyer_rating_stars = buyer_rating_stars
        self.buyer_num_ratings = buyer_num_ratings
        self.seller_rating = seller_rating
        self.seller_rating_stars = seller_rating_stars
        self.seller_num_ratings = seller_num_ratings
        self.curr_abbr = curr_abbr
    }
}

/// User submissions response
public struct UserSubmissionsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let submissions: UserSubmissions
    
    public init(pagination: Pagination, submissions: UserSubmissions) {
        self.pagination = pagination
        self.submissions = submissions
    }
}

/// User submissions breakdown
public struct UserSubmissions: Codable, Sendable {
    public let releases: [UserSubmissionItem]?
    public let labels: [UserSubmissionItem]?
    public let artists: [UserSubmissionItem]?
    
    public init(
        releases: [UserSubmissionItem]? = nil,
        labels: [UserSubmissionItem]? = nil,
        artists: [UserSubmissionItem]? = nil
    ) {
        self.releases = releases
        self.labels = labels
        self.artists = artists
    }
}

/// Individual submission item
public struct UserSubmissionItem: Codable, Sendable, Identifiable {
    public let id: Int
    public let title: String?
    public let name: String?
    public let resource_url: String
    public let year: Int?
    public let thumb: String?
    
    public init(
        id: Int,
        title: String? = nil,
        name: String? = nil,
        resource_url: String,
        year: Int? = nil,
        thumb: String? = nil
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.resource_url = resource_url
        self.year = year
        self.thumb = thumb
    }
}

/// User contributions response
public struct UserContributionsResponse: Codable, Sendable {
    public let pagination: Pagination
    public let contributions: [UserContribution]
    
    public init(pagination: Pagination, contributions: [UserContribution]) {
        self.pagination = pagination
        self.contributions = contributions
    }
}

/// Individual contribution
public struct UserContribution: Codable, Sendable, Identifiable {
    public let id: Int
    public let title: String?
    public let name: String?
    public let resource_url: String
    public let year: Int?
    public let thumb: String?
    public let type: String?  // "release", "artist", "label"
    
    public init(
        id: Int,
        title: String? = nil,
        name: String? = nil,
        resource_url: String,
        year: Int? = nil,
        thumb: String? = nil,
        type: String? = nil
    ) {
        self.id = id
        self.title = title
        self.name = name
        self.resource_url = resource_url
        self.year = year
        self.thumb = thumb
        self.type = type
    }
}
