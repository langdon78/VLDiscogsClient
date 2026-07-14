//
//  BasicInformationDecodingTests.swift
//  VLDiscogsClient
//

import Testing
import Foundation
@testable import VLDiscogsClient

@Suite("BasicInformation genres/styles decoding")
struct BasicInformationDecodingTests {

    @Test("Decodes genres and styles when present in the response")
    func testDecodesGenresAndStyles() throws {
        let json = """
        {
            "id": 2882977,
            "title": "Slippery When Wet",
            "year": 1986,
            "resource_url": "https://api.discogs.com/releases/2882977",
            "thumb": "https://example.com/thumb.jpg",
            "artists": [],
            "labels": [],
            "formats": [],
            "genres": ["Rock"],
            "styles": ["Soft Rock", "Hard Rock", "Arena Rock"]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(BasicInformation.self, from: json)

        #expect(decoded.genres == ["Rock"])
        #expect(decoded.styles == ["Soft Rock", "Hard Rock", "Arena Rock"])
    }

    @Test("Decodes to nil when genres/styles are absent, rather than failing")
    func testMissingGenresAndStylesDecodeToNil() throws {
        let json = """
        {
            "id": 7781525,
            "title": "The BBC Radio Sessions",
            "year": 2015,
            "resource_url": "https://api.discogs.com/releases/7781525",
            "thumb": "https://example.com/thumb.jpg",
            "artists": [],
            "labels": [],
            "formats": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(BasicInformation.self, from: json)

        #expect(decoded.genres == nil)
        #expect(decoded.styles == nil)
    }
}
