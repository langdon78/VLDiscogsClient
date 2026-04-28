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
    case userInventory(username: String, status: ListingStatus? = nil, sort: InventorySortField? = nil, sortOrder: SortOrderParameterValue? = nil, page: Int? = nil, perPage: Int? = nil)
    case marketplaceListings
    case marketplaceListing(listingId: Int, currAbbr: String? = nil)
    case marketplaceOrders(status: OrderStatus? = nil, archived: Bool? = nil, sort: OrderSortField? = nil, sortOrder: SortOrderParameterValue? = nil, page: Int? = nil, perPage: Int? = nil)
    case marketplaceOrder(orderId: String)
    case marketplaceOrderMessages(orderId: String, page: Int? = nil, perPage: Int? = nil)
    case marketplaceFee(price: Double)
    case marketplaceFeeWithCurrency(price: Double, currency: String)
    case marketplacePriceSuggestions(releaseId: Int)
    case marketplaceReleaseStatistics(releaseId: Int, currAbbr: String? = nil)
    case inventoryExports(page: Int? = nil, perPage: Int? = nil)
    case inventoryExport(id: Int)
    case inventoryExportDownload(id: Int)
    case wantlist(username: String, page: Int? = nil, perPage: Int? = nil)
    case wantlistItem(username: String, releaseId: Int)
    case userLists(username: String, page: Int? = nil, perPage: Int? = nil)
    case userList(listId: Int)
    case inventoryUploads(page: Int? = nil, perPage: Int? = nil)
    case inventoryUploadByType(type: InventoryUploadType)
    case inventoryUploadById(id: Int)

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

        case .userInventory(let username, let status, let sort, let sortOrder, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.inventory)")!
            var queryItems: [URLQueryItem] = []
            if let status { queryItems.append(URLQueryItem(name: "status", value: status.rawValue)) }
            if let sort { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sort)", value: sort.rawValue)) }
            if let sortOrder { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sortOrder)", value: sortOrder.rawValue)) }
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .marketplaceListings:
            urlString = "\(Self.baseURL)/\(Path.marketplace)/\(Path.listings)"

        case .marketplaceListing(let listingId, let currAbbr):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.marketplace)/\(Path.listings)/\(listingId)")!
            if let currAbbr { components.queryItems = [URLQueryItem(name: "curr_abbr", value: currAbbr)] }
            return components.url!

        case .marketplaceOrders(let status, let archived, let sort, let sortOrder, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.marketplace)/\(Path.orders)")!
            var queryItems: [URLQueryItem] = []
            if let status { queryItems.append(URLQueryItem(name: "status", value: status.rawValue)) }
            if let archived { queryItems.append(URLQueryItem(name: "archived", value: archived ? "1" : "0")) }
            if let sort { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sort)", value: sort.rawValue)) }
            if let sortOrder { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.sortOrder)", value: sortOrder.rawValue)) }
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .marketplaceOrder(let orderId):
            urlString = "\(Self.baseURL)/\(Path.marketplace)/\(Path.orders)/\(orderId)"

        case .marketplaceOrderMessages(let orderId, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.marketplace)/\(Path.orders)/\(orderId)/\(Path.messages)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .marketplaceFee(let price):
            urlString = "\(Self.baseURL)/\(Path.marketplace)/\(Path.fee)/\(price)"

        case .marketplaceFeeWithCurrency(let price, let currency):
            urlString = "\(Self.baseURL)/\(Path.marketplace)/\(Path.fee)/\(price)/\(currency)"

        case .marketplacePriceSuggestions(let releaseId):
            urlString = "\(Self.baseURL)/\(Path.marketplace)/price_suggestions/\(releaseId)"

        case .marketplaceReleaseStatistics(let releaseId, let currAbbr):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.marketplace)/\(Path.stats)/\(releaseId)")!
            if let currAbbr { components.queryItems = [URLQueryItem(name: "curr_abbr", value: currAbbr)] }
            return components.url!

        case .inventoryExports(let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.inventory)/export")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .inventoryExport(let id):
            urlString = "\(Self.baseURL)/\(Path.inventory)/export/\(id)"

        case .inventoryExportDownload(let id):
            urlString = "\(Self.baseURL)/\(Path.inventory)/export/\(id)/download"

        case .wantlist(let username, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.wants)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .wantlistItem(let username, let releaseId):
            urlString = "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.wants)/\(releaseId)"

        case .userLists(let username, let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.users)/\(username)/\(Path.lists)")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .userList(let listId):
            urlString = "\(Self.baseURL)/\(Path.lists)/\(listId)"

        case .inventoryUploads(let page, let perPage):
            var components = URLComponents(string: "\(Self.baseURL)/\(Path.inventory)/upload")!
            var queryItems: [URLQueryItem] = []
            if let page { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.page)", value: "\(page)")) }
            if let perPage { queryItems.append(URLQueryItem(name: "\(QueryParameterKey.perPage)", value: "\(perPage)")) }
            if !queryItems.isEmpty { components.queryItems = queryItems }
            return components.url!

        case .inventoryUploadByType(let type):
            urlString = "\(Self.baseURL)/\(Path.inventory)/upload/\(type.rawValue)"

        case .inventoryUploadById(let id):
            urlString = "\(Self.baseURL)/\(Path.inventory)/upload/\(id)"
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
        case marketplace
        case listings
        case orders
        case messages
        case fee
        case stats
        case inventory
        case wants
        case lists
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

    enum ListingStatus: String {
        case forSale = "For Sale"
        case draft = "Draft"
        case expired = "Expired"
        case sold = "Sold"
        case deleted = "Deleted"
    }

    enum ReleaseCondition: String {
        case mint = "Mint (M)"
        case nearMint = "Near Mint (NM or M-)"
        case veryGoodPlus = "Very Good Plus (VG+)"
        case veryGood = "Very Good (VG)"
        case goodPlus = "Good Plus (G+)"
        case good = "Good (G)"
        case fair = "Fair (F)"
        case poor = "Poor (P)"
        case notGraded = "Not Graded"
        case genericSleeve = "Generic Sleeve"
    }

    enum OrderStatus: String {
        case newOrder = "New Order"
        case buyerContacted = "Buyer Contacted"
        case invoiceSent = "Invoice Sent"
        case paymentPending = "Payment Pending"
        case paymentReceived = "Payment Received"
        case shipped = "Shipped"
        case refundSent = "Refund Sent"
        case cancelledNonPayingBuyer = "Cancelled (Non-Paying Buyer)"
        case cancelledItemUnavailable = "Cancelled (Item Unavailable)"
        case cancelledPerBuyersRequest = "Cancelled (Per Buyer's Request)"
        case merged = "Merged"
    }

    enum InventorySortField: String {
        case listed
        case price
        case item
        case artist
        case label
        case catno
        case audio
        case status
        case location
    }

    enum OrderSortField: String {
        case id
        case buyer
        case created
        case status
        case lastActivity = "last_activity"
    }

    enum InventoryUploadType: String {
        case add
        case change
        case delete
    }
}
