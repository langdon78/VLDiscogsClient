//
//  MarketplaceAPI.swift
//  VLDiscogsClient
//
//  Created by James Langdon on 4/27/26.
//

import Foundation
import VLNetworkingClient

public struct MarketplaceAPI: Sendable {
    let client: AsyncNetworkClientProtocol

    init(client: AsyncNetworkClientProtocol) {
        self.client = client
    }

    // MARK: - Inventory

    /// Get a seller's inventory
    public func inventory(
        username: String,
        status: DiscogsEndpoint.ListingStatus? = nil,
        sort: DiscogsEndpoint.InventorySortField? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> InventoryResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.userInventory(
                username: username,
                status: status,
                sort: sort,
                sortOrder: sortOrder,
                page: page,
                perPage: perPage
            ).url
        )
        return try await client.request(for: config).decode(InventoryResponse.self)
    }

    // MARK: - Listings

    /// Get a marketplace listing by ID
    public func listing(id: Int, currAbbr: String? = nil) async throws -> MarketplaceListing {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplaceListing(listingId: id, currAbbr: currAbbr).url)
        return try await client.request(for: config).decode(MarketplaceListing.self)
    }

    /// Create a new marketplace listing
    @discardableResult
    public func createListing(
        releaseId: Int,
        condition: DiscogsEndpoint.ReleaseCondition,
        sleeveCondition: DiscogsEndpoint.ReleaseCondition? = nil,
        price: Double,
        status: DiscogsEndpoint.ListingStatus,
        comments: String? = nil,
        allowOffers: Bool? = nil,
        videoUrl: String? = nil,
        externalId: String? = nil,
        location: String? = nil,
        weight: Int? = nil,
        formatQuantity: Int? = nil
    ) async throws -> CreateListingResponse {
        var body: [String: Any] = [
            "release_id": releaseId,
            "condition": condition.rawValue,
            "price": price,
            "status": status.rawValue
        ]
        if let sleeveCondition { body["sleeve_condition"] = sleeveCondition.rawValue }
        if let comments { body["comments"] = comments }
        if let allowOffers { body["allow_offers"] = allowOffers }
        if let videoUrl { body["video_url"] = videoUrl }
        if let externalId { body["external_id"] = externalId }
        if let location { body["location"] = location }
        if let weight { body["weight"] = weight }
        if let formatQuantity { body["format_quantity"] = formatQuantity }

        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceListings.url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(CreateListingResponse.self)
    }

    /// Edit an existing marketplace listing
    public func editListing(
        id: Int,
        releaseId: Int,
        condition: DiscogsEndpoint.ReleaseCondition,
        sleeveCondition: DiscogsEndpoint.ReleaseCondition? = nil,
        price: Double,
        status: DiscogsEndpoint.ListingStatus,
        comments: String? = nil,
        allowOffers: Bool? = nil,
        videoUrl: String? = nil,
        externalId: String? = nil,
        location: String? = nil,
        weight: Int? = nil,
        formatQuantity: Int? = nil
    ) async throws {
        var body: [String: Any] = [
            "release_id": releaseId,
            "condition": condition.rawValue,
            "price": price,
            "status": status.rawValue
        ]
        if let sleeveCondition { body["sleeve_condition"] = sleeveCondition.rawValue }
        if let comments { body["comments"] = comments }
        if let allowOffers { body["allow_offers"] = allowOffers }
        if let videoUrl { body["video_url"] = videoUrl }
        if let externalId { body["external_id"] = externalId }
        if let location { body["location"] = location }
        if let weight { body["weight"] = weight }
        if let formatQuantity { body["format_quantity"] = formatQuantity }

        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceListing(listingId: id).url,
            method: .POST,
            body: bodyData
        )
        _ = try await client.request(for: config)
    }

    /// Delete a marketplace listing
    public func deleteListing(id: Int) async throws {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceListing(listingId: id).url,
            method: .DELETE
        )
        _ = try await client.request(for: config)
    }

    // MARK: - Orders

    /// Get a marketplace order by ID
    public func order(id: String) async throws -> MarketplaceOrder {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplaceOrder(orderId: id).url)
        return try await client.request(for: config).decode(MarketplaceOrder.self)
    }

    /// Edit an order's status or shipping cost
    @discardableResult
    public func editOrder(
        id: String,
        status: DiscogsEndpoint.OrderStatus? = nil,
        shipping: Double? = nil
    ) async throws -> MarketplaceOrder {
        var body: [String: Any] = [:]
        if let status { body["status"] = status.rawValue }
        if let shipping { body["shipping"] = shipping }
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceOrder(orderId: id).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(MarketplaceOrder.self)
    }

    /// List all orders for the authenticated user
    public func orders(
        status: DiscogsEndpoint.OrderStatus? = nil,
        archived: Bool? = nil,
        sort: DiscogsEndpoint.OrderSortField? = nil,
        sortOrder: DiscogsEndpoint.SortOrderParameterValue? = nil,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> OrdersResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceOrders(
                status: status,
                archived: archived,
                sort: sort,
                sortOrder: sortOrder,
                page: page,
                perPage: perPage
            ).url
        )
        return try await client.request(for: config).decode(OrdersResponse.self)
    }

    // MARK: - Order Messages

    /// List messages for an order
    public func orderMessages(
        orderId: String,
        page: Int? = nil,
        perPage: Int? = nil
    ) async throws -> OrderMessagesResponse {
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceOrderMessages(orderId: orderId, page: page, perPage: perPage).url
        )
        return try await client.request(for: config).decode(OrderMessagesResponse.self)
    }

    /// Add a message to an order
    @discardableResult
    public func createOrderMessage(
        orderId: String,
        message: String? = nil,
        status: DiscogsEndpoint.OrderStatus? = nil
    ) async throws -> OrderMessage {
        var body: [String: Any] = [:]
        if let message { body["message"] = message }
        if let status { body["status"] = status.rawValue }
        let bodyData = try JSONSerialization.data(withJSONObject: body)
        let config = RequestConfiguration(
            url: DiscogsEndpoint.marketplaceOrderMessages(orderId: orderId).url,
            method: .POST,
            body: bodyData
        )
        return try await client.request(for: config).decode(OrderMessage.self)
    }

    // MARK: - Fee

    /// Calculate the Discogs marketplace fee for a given price
    public func fee(price: Double) async throws -> MarketplaceFee {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplaceFee(price: price).url)
        return try await client.request(for: config).decode(MarketplaceFee.self)
    }

    /// Calculate the Discogs marketplace fee in a specific currency
    public func fee(price: Double, currency: String) async throws -> MarketplaceFee {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplaceFeeWithCurrency(price: price, currency: currency).url)
        return try await client.request(for: config).decode(MarketplaceFee.self)
    }

    // MARK: - Price Suggestions & Statistics

    /// Get suggested prices per condition for a release
    public func priceSuggestions(releaseId: Int) async throws -> PriceSuggestions {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplacePriceSuggestions(releaseId: releaseId).url)
        return try await client.request(for: config).decode(PriceSuggestions.self)
    }

    /// Get marketplace statistics for a release
    public func releaseStatistics(releaseId: Int, currAbbr: String? = nil) async throws -> ReleaseStatistics {
        let config = RequestConfiguration(url: DiscogsEndpoint.marketplaceReleaseStatistics(releaseId: releaseId, currAbbr: currAbbr).url)
        return try await client.request(for: config).decode(ReleaseStatistics.self)
    }
}

// MARK: - Response Models

/// A monetary value with currency code
public struct Price: Codable, Sendable {
    public let currency: String
    public let value: Double

    public init(currency: String, value: Double) {
        self.currency = currency
        self.value = value
    }
}

/// A price with extended original-currency fields
public struct OriginalPrice: Codable, Sendable {
    public let curr_abbr: String?
    public let curr_id: Int?
    public let formatted: String?
    public let value: Double
    public let exchange_rate: Double?
    public let converted_value: Double?

    public init(
        curr_abbr: String? = nil,
        curr_id: Int? = nil,
        formatted: String? = nil,
        value: Double,
        exchange_rate: Double? = nil,
        converted_value: Double? = nil
    ) {
        self.curr_abbr = curr_abbr
        self.curr_id = curr_id
        self.formatted = formatted
        self.value = value
        self.exchange_rate = exchange_rate
        self.converted_value = converted_value
    }
}

/// A seller's rating statistics
public struct SellerStats: Codable, Sendable {
    public let rating: String?
    public let stars: Double?
    public let total: Int?

    public init(rating: String? = nil, stars: Double? = nil, total: Int? = nil) {
        self.rating = rating
        self.stars = stars
        self.total = total
    }
}

/// The seller associated with a marketplace listing
public struct ListingSeller: Codable, Sendable, Identifiable {
    public let id: Int
    public let username: String
    public let resource_url: String
    public let stats: SellerStats?
    public let min_order_total: Double?
    public let html_url: String?
    public let uid: Int?
    public let payment: String?
    public let shipping: String?
    public let avatar_url: String?

    public init(
        id: Int,
        username: String,
        resource_url: String,
        stats: SellerStats? = nil,
        min_order_total: Double? = nil,
        html_url: String? = nil,
        uid: Int? = nil,
        payment: String? = nil,
        shipping: String? = nil,
        avatar_url: String? = nil
    ) {
        self.id = id
        self.username = username
        self.resource_url = resource_url
        self.stats = stats
        self.min_order_total = min_order_total
        self.html_url = html_url
        self.uid = uid
        self.payment = payment
        self.shipping = shipping
        self.avatar_url = avatar_url
    }
}

/// A condensed release reference within a marketplace listing
public struct ListingRelease: Codable, Sendable, Identifiable {
    public let id: Int
    public let description: String?
    public let resource_url: String
    public let catalog_number: String?
    public let year: Int?
    public let artist: String?
    public let title: String?
    public let format: String?
    public let thumbnail: String?
    public let images: [DiscogsImage]?

    public init(
        id: Int,
        description: String? = nil,
        resource_url: String,
        catalog_number: String? = nil,
        year: Int? = nil,
        artist: String? = nil,
        title: String? = nil,
        format: String? = nil,
        thumbnail: String? = nil,
        images: [DiscogsImage]? = nil
    ) {
        self.id = id
        self.description = description
        self.resource_url = resource_url
        self.catalog_number = catalog_number
        self.year = year
        self.artist = artist
        self.title = title
        self.format = format
        self.thumbnail = thumbnail
        self.images = images
    }
}

/// A full marketplace listing
public struct MarketplaceListing: Codable, Sendable, Identifiable {
    public let id: Int
    public let resource_url: String
    public let uri: String?
    public let status: String
    public let condition: String
    public let sleeve_condition: String?
    public let comments: String?
    public let ships_from: String?
    public let posted: String?
    public let allow_offers: Bool?
    public let offer_submitted: Bool?
    public let audio: Bool?
    public let price: Price
    public let original_price: OriginalPrice?
    public let shipping_price: Price?
    public let original_shipping_price: OriginalPrice?
    public let seller: ListingSeller
    public let release: ListingRelease

    public init(
        id: Int,
        resource_url: String,
        uri: String? = nil,
        status: String,
        condition: String,
        sleeve_condition: String? = nil,
        comments: String? = nil,
        ships_from: String? = nil,
        posted: String? = nil,
        allow_offers: Bool? = nil,
        offer_submitted: Bool? = nil,
        audio: Bool? = nil,
        price: Price,
        original_price: OriginalPrice? = nil,
        shipping_price: Price? = nil,
        original_shipping_price: OriginalPrice? = nil,
        seller: ListingSeller,
        release: ListingRelease
    ) {
        self.id = id
        self.resource_url = resource_url
        self.uri = uri
        self.status = status
        self.condition = condition
        self.sleeve_condition = sleeve_condition
        self.comments = comments
        self.ships_from = ships_from
        self.posted = posted
        self.allow_offers = allow_offers
        self.offer_submitted = offer_submitted
        self.audio = audio
        self.price = price
        self.original_price = original_price
        self.shipping_price = shipping_price
        self.original_shipping_price = original_shipping_price
        self.seller = seller
        self.release = release
    }
}

/// Paginated seller inventory
public struct InventoryResponse: Codable, Sendable {
    public let pagination: Pagination
    public let listings: [MarketplaceListing]

    public init(pagination: Pagination, listings: [MarketplaceListing]) {
        self.pagination = pagination
        self.listings = listings
    }
}

/// Response when creating a new listing
public struct CreateListingResponse: Codable, Sendable {
    public let listing_id: Int
    public let resource_url: String

    public init(listing_id: Int, resource_url: String) {
        self.listing_id = listing_id
        self.resource_url = resource_url
    }
}

/// A release reference within an order item
public struct OrderItemRelease: Codable, Sendable, Identifiable {
    public let id: Int
    public let description: String?
    public let resource_url: String
    public let thumbnail: String?

    public init(
        id: Int,
        description: String? = nil,
        resource_url: String,
        thumbnail: String? = nil
    ) {
        self.id = id
        self.description = description
        self.resource_url = resource_url
        self.thumbnail = thumbnail
    }
}

/// A line item within a marketplace order
public struct OrderItem: Codable, Sendable, Identifiable {
    public let id: Int
    public let release: OrderItemRelease
    public let price: Price

    public init(id: Int, release: OrderItemRelease, price: Price) {
        self.id = id
        self.release = release
        self.price = price
    }
}

/// Shipping details for an order
public struct OrderShipping: Codable, Sendable {
    public let currency: String?
    public let method: String?
    public let value: Double?

    public init(currency: String? = nil, method: String? = nil, value: Double? = nil) {
        self.currency = currency
        self.method = method
        self.value = value
    }
}

/// A buyer or seller reference within an order
public struct OrderParticipant: Codable, Sendable, Identifiable {
    public let id: Int
    public let username: String
    public let resource_url: String

    public init(id: Int, username: String, resource_url: String) {
        self.id = id
        self.username = username
        self.resource_url = resource_url
    }
}

/// A full marketplace order
public struct MarketplaceOrder: Codable, Sendable, Identifiable {
    public let id: String
    public let resource_url: String
    public let messages_url: String?
    public let uri: String?
    public let status: String
    public let next_status: [String]?
    public let fee: Price?
    public let created: String?
    public let items: [OrderItem]
    public let shipping: OrderShipping?
    public let shipping_address: String?
    public let additional_instructions: String?
    public let archived: Bool?
    public let seller: OrderParticipant
    public let last_activity: String?
    public let buyer: OrderParticipant
    public let total: Price?

    public init(
        id: String,
        resource_url: String,
        messages_url: String? = nil,
        uri: String? = nil,
        status: String,
        next_status: [String]? = nil,
        fee: Price? = nil,
        created: String? = nil,
        items: [OrderItem],
        shipping: OrderShipping? = nil,
        shipping_address: String? = nil,
        additional_instructions: String? = nil,
        archived: Bool? = nil,
        seller: OrderParticipant,
        last_activity: String? = nil,
        buyer: OrderParticipant,
        total: Price? = nil
    ) {
        self.id = id
        self.resource_url = resource_url
        self.messages_url = messages_url
        self.uri = uri
        self.status = status
        self.next_status = next_status
        self.fee = fee
        self.created = created
        self.items = items
        self.shipping = shipping
        self.shipping_address = shipping_address
        self.additional_instructions = additional_instructions
        self.archived = archived
        self.seller = seller
        self.last_activity = last_activity
        self.buyer = buyer
        self.total = total
    }
}

/// Paginated list of orders
public struct OrdersResponse: Codable, Sendable {
    public let pagination: Pagination
    public let orders: [MarketplaceOrder]

    public init(pagination: Pagination, orders: [MarketplaceOrder]) {
        self.pagination = pagination
        self.orders = orders
    }
}

/// A reference back to an order, embedded in messages
public struct OrderReference: Codable, Sendable {
    public let id: String
    public let resource_url: String

    public init(id: String, resource_url: String) {
        self.id = id
        self.resource_url = resource_url
    }
}

/// The sender of an order message
public struct OrderMessageSender: Codable, Sendable, Identifiable {
    public let id: Int
    public let username: String
    public let resource_url: String
    public let avatar_url: String?

    public init(
        id: Int,
        username: String,
        resource_url: String,
        avatar_url: String? = nil
    ) {
        self.id = id
        self.username = username
        self.resource_url = resource_url
        self.avatar_url = avatar_url
    }
}

/// A single message on a marketplace order
public struct OrderMessage: Codable, Sendable {
    public let timestamp: String?
    public let message: String?
    public let type: String?
    public let subject: String?
    public let from: OrderMessageSender?
    public let order: OrderReference?

    public init(
        timestamp: String? = nil,
        message: String? = nil,
        type: String? = nil,
        subject: String? = nil,
        from: OrderMessageSender? = nil,
        order: OrderReference? = nil
    ) {
        self.timestamp = timestamp
        self.message = message
        self.type = type
        self.subject = subject
        self.from = from
        self.order = order
    }
}

/// Paginated list of order messages
public struct OrderMessagesResponse: Codable, Sendable {
    public let pagination: Pagination
    public let messages: [OrderMessage]

    public init(pagination: Pagination, messages: [OrderMessage]) {
        self.pagination = pagination
        self.messages = messages
    }
}

/// Discogs marketplace fee for a given price
public struct MarketplaceFee: Codable, Sendable {
    public let value: Double
    public let currency: String

    public init(value: Double, currency: String) {
        self.value = value
        self.currency = currency
    }
}

/// Suggested prices per condition for a release
/// Keys are condition strings (e.g. "Mint (M)", "Very Good Plus (VG+)")
public struct PriceSuggestions: Codable, Sendable {
    private let suggestions: [String: Price]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        suggestions = try container.decode([String: Price].self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(suggestions)
    }

    public subscript(condition: DiscogsEndpoint.ReleaseCondition) -> Price? {
        suggestions[condition.rawValue]
    }

    public subscript(conditionString: String) -> Price? {
        suggestions[conditionString]
    }

    public var all: [String: Price] { suggestions }
}

/// Marketplace statistics for a release
public struct ReleaseStatistics: Codable, Sendable {
    public let lowest_price: Price?
    public let num_for_sale: Int?
    public let blocked_from_sale: Bool?

    public init(
        lowest_price: Price? = nil,
        num_for_sale: Int? = nil,
        blocked_from_sale: Bool? = nil
    ) {
        self.lowest_price = lowest_price
        self.num_for_sale = num_for_sale
        self.blocked_from_sale = blocked_from_sale
    }
}
