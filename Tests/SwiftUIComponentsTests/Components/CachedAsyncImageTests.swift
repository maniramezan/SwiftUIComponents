import DesignSystem
import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import Components

@MainActor
@Suite("CachedAsyncImage", .serialized)
struct CachedAsyncImageTests {
    private actor SpyCache: ImageCacheStore {
        let data: Data
        let fails: Bool
        private(set) var requests = 0
        private(set) var removals = 0

        init(data: Data, fails: Bool = false) {
            self.data = data
            self.fails = fails
        }

        func imageData(for url: URL) async throws -> Data {
            requests += 1
            if fails { throw CacheError.unavailable }
            return data
        }

        func removeValue(for url: URL) async throws { removals += 1 }
        enum CacheError: Error { case unavailable }
    }

    private static let png =
        Data(
            base64Encoded:
                "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a5N8AAAAASUVORK5CYII=")
        ?? Data()

    @Test("The production loader decodes once per current request and isolates stores")
    func storeIdentity() async throws {
        let url = try #require(URL(string: "https://example.com/image.png"))
        let first = SpyCache(data: Self.png)
        let second = SpyCache(data: Self.png)
        let loader = CachedImageLoader()
        await loader.load(url: url, cache: first)
        #expect(loader.image != nil)
        await loader.load(url: url, cache: first)
        #expect(await first.requests == 1)
        await loader.load(url: url, cache: second)
        #expect(loader.image != nil)
        #expect(await second.requests == 1)
        await loader.load(url: nil, cache: second)
        #expect(loader.image == nil)
        #expect(await second.requests == 1)
    }

    @Test("Invalid bytes are evicted and failed requests retain the placeholder")
    func failures() async throws {
        let url = try #require(URL(string: "https://example.com/image.png"))
        let invalid = SpyCache(data: Data())
        let failed = SpyCache(data: Self.png, fails: true)
        let loader = CachedImageLoader()
        await loader.load(url: url, cache: invalid)
        #expect(loader.image == nil)
        #expect(await invalid.removals == 1)
        await loader.load(url: url, cache: failed)
        #expect(loader.image == nil)
        #expect(await failed.requests == 1)
        await loader.load(url: url, cache: nil)
        #expect(loader.image == nil)
    }

    @Test("Replacing the environment store restarts the mounted view at the same URL")
    func environmentReplacement() async throws {
        let url = try #require(URL(string: "https://example.com/image.png"))
        let first = SpyCache(data: Self.png)
        let second = SpyCache(data: Self.png)
        let model = ImageTestModel(cache: first)
        let host = HostedView(ImageTestHost(url: url, model: model), size: CGSize(width: 100, height: 100))
        defer { host.close() }
        for _ in 0..<100 {
            if await first.requests > 0 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(await first.requests == 1)
        model.cache = second
        for _ in 0..<100 {
            if await second.requests > 0 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(await second.requests == 1)
    }

    @Test("A superseded store cannot overwrite the latest request when it finishes late")
    func supersededResult() async throws {
        let url = try #require(URL(string: "https://example.com/image.png"))
        let first = SuspendedImageCache()
        let second = SpyCache(data: Self.png)
        let loader = CachedImageLoader()
        let oldLoad = Task { await loader.load(url: url, cache: first) }
        try await waitForRequest(first)
        await loader.load(url: url, cache: second)
        let current = loader.image
        await first.finish(Data())
        await oldLoad.value
        #expect(loader.image == current)
        #expect(loader.request == CachedImageRequest(url: url, cache: second))
    }

    @Test("Cancelled loads never publish decoded content")
    func cancellation() async throws {
        let url = try #require(URL(string: "https://example.com/image.png"))
        let cache = SuspendedImageCache()
        let loader = CachedImageLoader()
        let load = Task { await loader.load(url: url, cache: cache) }
        try await waitForRequest(cache)
        load.cancel()
        await cache.finish(Self.png)
        await load.value
        #expect(loader.image == nil)
    }
    private func waitForRequest(_ cache: SuspendedImageCache) async throws {
        for _ in 0..<100 {
            if await cache.isWaiting { return }
            try await Task.sleep(for: .milliseconds(10))
        }
        try #require(await cache.isWaiting)
    }

}

@MainActor
@Observable
private final class ImageTestModel {
    var cache: any ImageCacheStore
    init(cache: any ImageCacheStore) { self.cache = cache }
}

private struct ImageTestHost: View {
    let url: URL
    let model: ImageTestModel
    var body: some View {
        CachedAsyncImage(url: url) {
            $0
        } placeholder: {
            Color.clear
        }
        .imageCache(model.cache)
    }
}

private actor SuspendedImageCache: ImageCacheStore {
    private var continuation: CheckedContinuation<Data, Never>?
    var isWaiting: Bool { continuation != nil }
    func imageData(for url: URL) async throws -> Data {
        await withCheckedContinuation { continuation = $0 }
    }
    func removeValue(for url: URL) async throws {}
    func finish(_ data: Data) {
        continuation?.resume(returning: data)
        continuation = nil
    }
}
