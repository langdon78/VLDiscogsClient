//
//  ReleaseVideoDecodingTests.swift
//  VLDiscogsClient
//

import Testing
import Foundation
@testable import VLDiscogsClient

@Suite("Release.videos lenient decoding")
struct ReleaseVideoDecodingTests {

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

    @Test("A video with null title/description decodes and is kept — the reported bug")
    func testNullDescriptionVideoDecodesWithoutThrowing() throws {
        // The exact shape that failed in the wild (VLOrganizer VIN-333):
        // user-contributed videos carry null title/description when the
        // contributor left them blank, and one such entry used to fail the
        // whole Release decode — tracklist included.
        let json = """
        {
            \(Self.minimalReleaseFields),
            "videos": [
                {"uri": "https://youtube.com/watch?v=abc", "title": null, "description": null, "duration": 262, "embed": true},
                {"uri": "https://youtube.com/watch?v=def", "title": "Ohio", "description": "Official video", "duration": 195, "embed": true}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.videos?.count == 2)
        #expect(decoded.videos?.first?.title == nil)
        #expect(decoded.videos?.first?.description == nil)
        #expect(decoded.videos?.first?.uri == "https://youtube.com/watch?v=abc")
        #expect(decoded.videos?.last?.title == "Ohio")
    }

    @Test("A structurally malformed video entry is dropped, not contagious")
    func testMalformedVideoEntryIsDroppedAndRestKept() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "videos": [
                "not an object at all",
                {"uri": "https://youtube.com/watch?v=abc", "title": "Kept", "description": null, "duration": 100, "embed": false},
                {"title": "missing required uri", "duration": 100, "embed": false}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.videos?.count == 1)
        #expect(decoded.videos?.first?.title == "Kept")
    }

    @Test("Missing videos key decodes to nil")
    func testMissingVideosDecodesToNil() throws {
        let json = "{\(Self.minimalReleaseFields)}".data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.videos == nil)
    }

    @Test("Explicit null videos decodes to nil")
    func testNullVideosDecodesToNil() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "videos": null
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)

        #expect(decoded.videos == nil)
    }

    @Test("Release round-trips through encode after a lossy decode")
    func testEncodeAfterLossyDecodeRoundTrips() throws {
        let json = """
        {
            \(Self.minimalReleaseFields),
            "videos": [
                {"uri": "https://youtube.com/watch?v=abc", "title": null, "description": null, "duration": 1, "embed": false}
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Release.self, from: json)
        let reencoded = try JSONEncoder().encode(decoded)
        let redecoded = try JSONDecoder().decode(Release.self, from: reencoded)

        #expect(redecoded.videos?.count == 1)
        #expect(redecoded.videos?.first?.uri == "https://youtube.com/watch?v=abc")
    }
}
