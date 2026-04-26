//
//  DiscogsEndpoint.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

struct Endpoints {
    static let baseURL = "https://api.discogs.com"
}

extension Endpoints {
    struct Reference {
        // Placeholders
        static let username = "{username}"
        static let folderId = "{folder_id}"
        static let releaseId = "{release_id}"
    }
}

/// Discogs API endpoints
public enum DiscogsEndpoint {
    case identity
    case release(id: Int)
    case artist(id: Int)
    case label(id: Int)
    case master(id: Int)
    case collectionFolders(username: String = "{username}")
    case collectionFolder(username: String, folderId: Int)
    case collectionItemsByRelease(username: String, releaseId: Int, page: Int? = nil, perPage: Int? = nil)
    case collectionItemsByFolder(username: String, folderId: Int, page: Int? = nil, perPage: Int? = nil, sort: SortParameterValue? = nil, sortOrder: SortOrderParameterValue? = nil)
    case addReleaseToFolder(username: String, folderId: Int, releaseId: Int)
    case editReleaseInstance(username: String, folderId: Int, releaseId: Int, instanceId: Int)
    case collectionFields(username: String)
    case collectionValue(username: String)
    case search(query: String, type: SearchType? = nil, page: Int? = nil, perPage: Int? = nil)
    case userProfile(username: String)
    case userSubmissions(username: String, page: Int? = nil, perPage: Int? = nil)
    case userContributions(username: String, page: Int? = nil, perPage: Int? = nil, sort: String? = nil, sortOrder: String? = nil)
    case releaseRating(releaseId: Int, username: String)
    case communityReleaseRating(releaseId: Int)
    case masterVersions(masterId: Int, page: Int? = nil, perPage: Int? = nil)
    case artistReleases(artistId: Int, page: Int? = nil, perPage: Int? = nil, sort: SortParameterValue? = nil, sortOrder: SortOrderParameterValue? = nil)
    case labelReleases(labelId: Int, page: Int? = nil, perPage: Int? = nil, sort: SortParameterValue? = nil, sortOrder: SortOrderParameterValue? = nil)

    private static let baseURL = "https://api.discogs.com"

    /// URL for the endpoint
    public var url: URL {
        let urlString: String

        switch self {
        case .identity:
            urlString = "\(Self.baseURL)/oauth/identity"

        case .release(let id):
            urlString = "\(Self.baseURL)/\(Path.releases)/\(id)"

        case .artist(let id):
            urlString = "\(Self.baseURL)/\(Path.artists)/\(id)"

        case .label(let id):
            urlString = "\(Self.baseURL)/\(Path.labels)/\(id)"

        case .master(let id):
            urlString = "\(Self.baseURL)/\(Path.masters)/\(id)"

        case .collectionFolders(let username):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.folders)"

        case .collectionFolder(let username, let folderId):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.folders)/\(folderId)"

        case .collectionItemsByRelease(let username, let releaseId, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.releases)/\(releaseId)")!
            var queryItems: [URLQueryItem] = []

            if let page = page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let perPage = perPage {
                queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            }

            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            return components.url!
        case .collectionItemsByFolder(
            let username,
            let folderId,
            let page,
            let perPage,
            let sort,
            let sortOrder
        ):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.folders)/\(folderId)/\(Path.releases)")!
            var queryItems: [URLQueryItem] = []

            if let page = page {
                queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)"))
            }
            if let perPage = perPage {
                queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)"))
            }
            if let sort {
                queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sort)", value: "\(sort)"))
            }
            if let sortOrder {
                queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sortOrder)", value: "\(sortOrder)"))
            }
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            return components.url!
            
        case .addReleaseToFolder(let username, let folderId, let releaseId):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.folders)/\(folderId)/\(Path.releases)/\(releaseId)"
            
        case .editReleaseInstance(let username, let folderId, let releaseId, let instanceId):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/\(Path.folders)/\(folderId)/\(Path.releases)/\(releaseId)/instances/\(instanceId)"
            
        case .collectionFields(let username):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/fields"
            
        case .collectionValue(let username):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.collection)/value"
        
        case .search(let query, let type, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/database/search")!
            var queryItems: [URLQueryItem] = [
                URLQueryItem(name: "q", value: query)
            ]

            if let type = type {
                queryItems.append(URLQueryItem(name: "type", value: type.rawValue))
            }
            if let page = page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let perPage = perPage {
                queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            }

            components.queryItems = queryItems
            return components.url!
            
        case .userProfile(let username):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)"
            
        case .userSubmissions(let username, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/submissions")!
            var queryItems: [URLQueryItem] = []
            
            if let page = page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let perPage = perPage {
                queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            }
            
            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            return components.url!
            
        case .userContributions(let username, let page, let perPage, let sort, let sortOrder):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/contributions")!
            var queryItems: [URLQueryItem] = []

            if let page = page {
                queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
            }
            if let perPage = perPage {
                queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
            }
            if let sort = sort {
                queryItems.append(URLQueryItem(name: "sort", value: sort))
            }
            if let sortOrder = sortOrder {
                queryItems.append(URLQueryItem(name: "sort_order", value: sortOrder))
            }

            if !queryItems.isEmpty {
                components.queryItems = queryItems
            }
            return components.url!

        case .releaseRating(let releaseId, let username):
            urlString = "\(Self.baseURL)/\(Path.releases)/\(releaseId)/\(Path.rating)/\(username)"

        case .communityReleaseRating(let releaseId):
            urlString = "\(Self.baseURL)/\(Path.releases)/\(releaseId)/\(Path.rating)"

        case .masterVersions(let masterId, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.masters)/\(masterId)/\(Path.versions)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .artistReleases(let artistId, let page, let perPage, let sort, let sortOrder):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.artists)/\(artistId)/\(Path.releases)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if let sort { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sort)", value: "\(sort)")) }
            if let sortOrder { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sortOrder)", value: "\(sortOrder)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .labelReleases(let labelId, let page, let perPage, let sort, let sortOrder):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.labels)/\(labelId)/\(Path.releases)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if let sort { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sort)", value: "\(sort)")) }
            if let sortOrder { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sortOrder)", value: "\(sortOrder)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!
        }

        return URL(string: urlString)!
    }
}

public extension DiscogsEndpoint {
    
    /// Paths for Discogs API routes
    enum Path: String {
        case collection
        case users
        case folders
        case releases
        case masters
        case artists
        case labels
        case rating
        case versions
    }
    
    /// Search types for Discogs database search
    enum SearchType: String {
        case release
        case master
        case artist
        case label
    }
    
    /// Query parameters
    enum QueryParameterKey: String {
        case sort
        case sortOrder = "sort_order"
        case page
        case perPage = "per_page"
    }
    
    enum SortParameterValue: String {
        case label
        case artist
        case title
        case catno
        case format
        case rating
        case added
        case year
    }
    
    enum SortOrderParameterValue: String {
        case asc
        case desc
    }
}
