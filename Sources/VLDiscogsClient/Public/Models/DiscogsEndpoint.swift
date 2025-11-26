//
//  DiscogsEndpoint.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 11/25/25.
//

import Foundation

/// Discogs API endpoints
public enum DiscogsEndpoint {
    case identity
    case release(id: Int)
    case artist(id: Int)
    case label(id: Int)
    case master(id: Int)
    case collectionFolders(username: String)
    case collectionFolder(username: String, folderId: Int)
    case search(query: String, type: SearchType? = nil, page: Int? = nil, perPage: Int? = nil)

    private static let baseURL = "https://api.discogs.com"

    /// URL for the endpoint
    public var url: URL {
        let urlString: String

        switch self {
        case .identity:
            urlString = "\(Self.baseURL)/oauth/identity"

        case .release(let id):
            urlString = "\(Self.baseURL)/releases/\(id)"

        case .artist(let id):
            urlString = "\(Self.baseURL)/artists/\(id)"

        case .label(let id):
            urlString = "\(Self.baseURL)/labels/\(id)"

        case .master(let id):
            urlString = "\(Self.baseURL)/masters/\(id)"

        case .collectionFolders(let username):
            urlString = "\(Self.baseURL)/users/\(username)/collection/folders"

        case .collectionFolder(let username, let folderId):
            urlString = "\(Self.baseURL)/users/\(username)/collection/folders/\(folderId)"

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

/// Search types for Discogs database search
public enum SearchType: String {
    case release
    case master
    case artist
    case label
}
