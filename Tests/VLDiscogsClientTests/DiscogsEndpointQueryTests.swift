import Foundation
import Testing
@testable import VLDiscogsClient

/// Regression tests for the query-parameter names actually sent on the
/// wire. Swift's default enum interpolation yields the CASE NAME, not the
/// raw value — `perPage`/`sortOrder` were sent literally for the library's
/// entire life, Discogs ignored the unknown keys, and pagination silently
/// ran at the server default of 50. These tests pin the wire names so the
/// CustomStringConvertible conformance can't be "simplified" away.
struct DiscogsEndpointQueryTests {
    private func queryDictionary(_ url: URL) -> [String: String] {
        let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        return Dictionary(uniqueKeysWithValues: items.map { ($0.name, $0.value ?? "") })
    }

    @Test func collectionItemsByFolderSendsWireParameterNames() {
        let url = DiscogsEndpoint.collectionItemsByFolder(
            username: "u", folderId: 0, page: 2, perPage: 100, sort: .added, sortOrder: .desc
        ).url
        let query = queryDictionary(url)
        #expect(query["page"] == "2")
        #expect(query["per_page"] == "100")
        #expect(query["sort"] == "added")
        #expect(query["sort_order"] == "desc")
        #expect(query["perPage"] == nil)
        #expect(query["sortOrder"] == nil)
    }

    @Test func artistAndLabelReleasesSendWireParameterNames() {
        for url in [
            DiscogsEndpoint.artistReleases(artistId: 1, page: 1, perPage: 75, sort: .year, sortOrder: .asc).url,
            DiscogsEndpoint.labelReleases(labelId: 1, page: 1, perPage: 75, sort: .year, sortOrder: .asc).url,
        ] {
            let query = queryDictionary(url)
            #expect(query["per_page"] == "75")
            #expect(query["sort_order"] == "asc")
            #expect(query["perPage"] == nil)
        }
    }
}
