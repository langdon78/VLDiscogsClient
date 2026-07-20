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

    @Test("Decodes cover_image when present in the response")
    func testDecodesCoverImage() throws {
        let json = """
        {
            "id": 2882977,
            "title": "Slippery When Wet",
            "year": 1986,
            "resource_url": "https://api.discogs.com/releases/2882977",
            "thumb": "https://example.com/thumb-150.jpg",
            "cover_image": "https://example.com/cover-500.jpg",
            "artists": [],
            "labels": [],
            "formats": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(BasicInformation.self, from: json)

        #expect(decoded.cover_image == "https://example.com/cover-500.jpg")
    }

    @Test("Decodes to nil when cover_image is absent, rather than failing")
    func testMissingCoverImageDecodesToNil() throws {
        let json = """
        {
            "id": 7781525,
            "title": "The BBC Radio Sessions",
            "year": 2015,
            "resource_url": "https://api.discogs.com/releases/7781525",
            "thumb": "https://example.com/thumb-150.jpg",
            "artists": [],
            "labels": [],
            "formats": []
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(BasicInformation.self, from: json)

        #expect(decoded.cover_image == nil)
    }
}
