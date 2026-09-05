//
//  LossyDecodableArray.swift
//  VLDiscogsClient
//

import Foundation

/// Decodes an array element-by-element, dropping entries that fail to
/// decode instead of failing the whole containing response.
///
/// Motivated by the same field-provenance problem `DiscogsSeriesEntry`
/// solved for `series`: parts of a Discogs release response are
/// user-contributed and structurally unreliable, and a single malformed
/// entry in an *ancillary* array used to throw for the entire `Release` —
/// taking the tracklist down with it (VLOrganizer VIN-333: one video with
/// a `null` description made a release's whole detail screen undecodable).
/// Ancillary lists should degrade by omission, never by contagion.
///
/// Applied via property wrapper so the containing model keeps its
/// synthesized `Codable` conformance (the `DiscogsSeriesEntry` precedent's
/// same goal, achieved at the array level rather than the element level).
@propertyWrapper
public struct LossyDecodableArray<Element: Codable & Sendable>: Codable, Sendable {
    public var wrappedValue: [Element]?

    public init(wrappedValue: [Element]?) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: Decoder) throws {
        if let single = try? decoder.singleValueContainer(), single.decodeNil() {
            wrappedValue = nil
            return
        }
        var container = try decoder.unkeyedContainer()
        var elements: [Element] = []
        while !container.isAtEnd {
            if let element = try? container.decode(Element.self) {
                elements.append(element)
            } else {
                // A failed decode doesn't advance the container — consume
                // the malformed entry with a decode that accepts any shape,
                // so the loop can't spin on it.
                _ = try? container.decode(AnyShapeStub.self)
            }
        }
        wrappedValue = elements
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let wrappedValue {
            try container.encode(wrappedValue)
        } else {
            try container.encodeNil()
        }
    }

    /// Succeeds for any JSON value without reading it — the "skip one
    /// entry" primitive.
    private struct AnyShapeStub: Decodable {
        init(from decoder: Decoder) throws {}
    }
}

public extension KeyedDecodingContainer {
    /// Synthesized `Codable` calls plain `decode` for property-wrapped
    /// fields, which throws on a missing key — this restores the
    /// `decodeIfPresent` behavior an optional array field had before it
    /// was wrapped, so an absent key still decodes as `nil`.
    func decode<T>(_ type: LossyDecodableArray<T>.Type, forKey key: Key) throws -> LossyDecodableArray<T> {
        try decodeIfPresent(type, forKey: key) ?? LossyDecodableArray(wrappedValue: nil)
    }
}
