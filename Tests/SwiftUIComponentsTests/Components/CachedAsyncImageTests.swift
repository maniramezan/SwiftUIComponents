import Components
import DesignSystem
import Foundation
import SwiftUI
import Testing

@MainActor
@Suite("CachedAsyncImage")
struct CachedAsyncImageTests {

    private actor SpyCache: ImageCacheStore {
        var requestedURLs: [URL] = []
        var stubbedData: Data = Data()
        var shouldThrow = false

        func imageData(for url: URL) async throws -> Data {
            requestedURLs.append(url)
            if shouldThrow { throw CacheError.unavailable }
            return stubbedData
        }

        func removeValue(for url: URL) async throws {
            // no-op for test
        }

        enum CacheError: Error { case unavailable }
    }

    @Test("nil URL keeps placeholder visible without calling cache")
    func nilURL() async {
        let cache = SpyCache()
        let view = CachedAsyncImage(url: nil, cache: cache) { image in
            image
        } placeholder: {
            Color.gray
        }
        _ = view
        let urls = await cache.requestedURLs
        #expect(urls.isEmpty)
    }

    @Test("explicit cache init is constructible")
    func explicitCache() {
        let cache = SpyCache()
        let url = URL(string: "https://example.com/img.png")
        _ = CachedAsyncImage(url: url, cache: cache) {
            $0
        } placeholder: {
            Color.clear
        }
    }

    @Test("environment-only init is constructible without explicit cache")
    func environmentInit() {
        let url = URL(string: "https://example.com/img.png")
        _ = CachedAsyncImage(url: url) { image in
            image
        } placeholder: {
            Color.clear
        }
    }

    @Test("environment cache modifier applies without crash")
    func environmentModifier() {
        let cache = SpyCache()
        _ = Color.clear.imageCache(cache)
    }
}
