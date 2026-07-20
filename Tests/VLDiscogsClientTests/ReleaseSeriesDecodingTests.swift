//
//  ReleaseSeriesDecodingTests.swift
//  VLDiscogsClient
//

import Testing
import Foundation
@testable import VLDiscogsClient

@Suite("Release.series lenient decoding")
struct ReleaseSeriesDecodingTests {

    private static let minimalReleaseFields = """
        "id": 1,
        "status": "Accepted",
        "resource_url": "https://api.discogs.com/releases/1",
        "uri": "https://www.discogs.com/release/1",
        "artists": [],
        "labels": [],
        "formats": [{"name": "Vinyl", "qty": "1"}],
        "data_quality": "Correct",
        "format_quantity": 1,
        "title": "Test Release",
        "tracklist": []
        """

    @Test("Decodes series as plain strings")
    func testDecodesSeriesAsStrings() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "series": ["A Perfect Circle Box Set Series"]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.series?.count == 1)
        #expect(decoded.series?.first?.name == "A Perfect Circle Box Set Series")
        #expect(decoded.series?.first?.id == nil)
    }

    @Test("Decodes series as label-shaped objects without throwing — the reported bug")
    func testDecodesSeriesAsObjectsWithoutThrowing() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "series": [
                {
                    "id": 12345,
                    "name": "A Perfect Circle Box Set Series",
                    "catno": "none",
                    "resource_url": "https://api.discogs.com/labels/12345"
                }
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.series?.count == 1)
        #expect(decoded.series?.first?.name == "A Perfect Circle Box Set Series")
        #expect(decoded.series?.first?.id == 12345)
        #expect(decoded.series?.first?.catno == "none")
    }

    @Test("Decodes to nil when series is absent, rather than failing")
    func testMissingSeriesDecodesToNil() throws {
        let json = """
        {
            \(Self.minimalReleaseFields)
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.series == nil)
    }

    @Test("A mixed array of strings and objects decodes every entry")
    func testMixedStringAndObjectSeriesEntriesAllDecode() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "series": [
                "Plain String Series",
                {"id": 1, "name": "Object Series"}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.series?.map(\.name) == ["Plain String Series", "Object Series"])
    }
}
