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
    case search(query: String, type: SearchType? = nil, page: Int? = nil, perPage: Int? = nil)

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
        }

        return URL(string: urlString)!
    }
}

public extension DiscogsEndpoint {
    
    /// Paths for Discogs API routes
    public enum Path: String {
        case collection
        case users
        case folders
        case releases
        case masters
        case artists
        case labels
    }
    
    /// Search types for Discogs database search
    public enum SearchType: String {
        case release
        case master
        case artist
        case label
    }
    
    /// Query parameters
    public enum QueryParameterKey: String {
        case sort
        case sortOrder = "sort_order"
        case page
        case perPage = "per_page"
    }
    
    public enum SortParameterValue: String {
        case label
        case artist
        case title
        case catno
        case format
        case rating
        case added
        case year
    }
    
    public enum SortOrderParameterValue: String {
        case asc
        case desc
    }
}
