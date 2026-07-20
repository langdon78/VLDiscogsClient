//
//  DiscogsSeriesEntry.swift
//  VLDiscogsClient
//

import Foundation

/// Discogs's `series` field on a release response is inconsistent across
/// releases: sometimes an array of plain strings, sometimes an array of
/// label-shaped objects (the same `id`/`name`/`catno`/`resource_url` shape
/// `LabelReference` already models). Confirmed against a real release
/// response that decoding `Release.series` as `[String]?` throws
/// `DecodingError.typeMismatch` when Discogs sends the object form —
/// this normalizes both shapes into one type so `Release.series:
/// [DiscogsSeriesEntry]?` decodes successfully either way.
public struct DiscogsSeriesEntry: Codable, Sendable {
    public let name: String
    public let id: Int?
    public let catno: String?
    public let resource_url: String?

    public init(name: String, id: Int? = nil, catno: String? = nil, resource_url: String? = nil) {
        self.name = name
        self.id = id
        self.catno = catno
        self.resource_url = resource_url
    }

    private enum CodingKeys: String, CodingKey {
        case name, id, catno, resource_url
    }

    public init(from decoder: Decoder) throws {
        // The plain-string form — the whole entry *is* the name.
        if let single = try? decoder.singleValueContainer(), let string = try? single.decode(String.self) {
            self.name = string
            self.id = nil
            self.catno = nil
            self.resource_url = nil
            return
        }

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = try container.decodeIfPresent(Int.self, forKey: .id)
        self.catno = try container.decodeIfPresent(String.self, forKey: .catno)
        self.resource_url = try container.decodeIfPresent(String.self, forKey: .resource_url)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(catno, forKey: .catno)
        try container.encodeIfPresent(resource_url, forKey: .resource_url)
    }
}
