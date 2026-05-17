import Foundation

/// Minimum surface required by `CachedAsyncImage` to fetch and invalidate
/// image data for a URL.
///
/// Adopt this protocol on your app's existing image cache, downloader, or
/// any actor that exposes async data fetching. The protocol intentionally
/// stays small — storage policy, eviction strategy, on-disk format, and
/// background download behavior all stay in the conforming type.
///
/// ```swift
/// extension MyAppImageCache: ImageCacheStore {
///     func imageData(for url: URL) async throws -> Data { ... }
///     func removeValue(for url: URL) async throws { ... }
/// }
/// ```
public protocol ImageCacheStore: Sendable {

    /// Returns the raw bytes for the image at `url`, fetching and caching
    /// them as needed.
    ///
    /// - Parameter url: The image URL.
    /// - Returns: The image bytes, ready to be decoded into a platform image.
    /// - Throws: Any error produced by the underlying network or storage layer.
    func imageData(for url: URL) async throws -> Data

    /// Removes any cached entry for `url` so the next `imageData(for:)` call
    /// will refetch from the source of truth.
    ///
    /// - Parameter url: The image URL whose cached entry should be evicted.
    /// - Throws: Any error produced by the underlying storage layer.
    func removeValue(for url: URL) async throws
}
