import DesignSystem
import OSLog
import SwiftUI

#if canImport(UIKit)
    import UIKit
    private typealias PlatformImage = UIImage
#elseif canImport(AppKit)
    import AppKit
    private typealias PlatformImage = NSImage
#endif

/// Loads an image from a URL through any `ImageCacheStore`, decodes it once,
/// and re-uses the decoded result across re-renders.
///
/// The view layers two caches:
/// 1. The caller-supplied `ImageCacheStore` returns the raw bytes — usually
///    backed by memory plus disk for cross-launch persistence.
/// 2. A view-local `NSCache` retains the decoded platform image so scrolling
///    a long list of the same URLs does not re-decode on every cell appearance.
///
/// While the URL is still being fetched the `placeholder` view is shown.
/// Passing a `nil` URL keeps the placeholder visible without scheduling any
/// load.
///
/// ```swift
/// // Option 1: Explicit cache parameter
/// CachedAsyncImage(url: profile.avatarURL, cache: myCache) { image in
///     image.resizable().scaledToFill()
/// } placeholder: {
///     Color.gray.opacity(0.2)
/// }
///
/// // Option 2: Inject cache once at the root and omit the parameter
/// ContentView()
///     .imageCache(MyAppImageCache.shared)
///
/// // Then in any descendant view:
/// CachedAsyncImage(url: profile.avatarURL) { image in
///     image.resizable().scaledToFill()
/// } placeholder: {
///     Color.gray.opacity(0.2)
/// }
/// ```
@MainActor
public struct CachedAsyncImage<Content: View, Placeholder: View>: View {

    private let url: URL?
    private let explicitCache: (any ImageCacheStore)?
    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder

    @State private var image: Image?
    @State private var loadedURL: URL?
    @Environment(\.imageCache) private var environmentCache

    private var resolvedCache: (any ImageCacheStore)? {
        explicitCache ?? environmentCache
    }

    private static var logger: Logger {
        Logger(subsystem: "com.swiftuicomponents", category: "CachedAsyncImage")
    }

    /// Creates a cached async image view with an explicit cache.
    ///
    /// - Parameters:
    ///   - url: The image URL. Pass `nil` to leave the placeholder showing
    ///     without starting a load.
    ///   - cache: The byte-level cache that will fetch and store the image
    ///     data on the caller's behalf.
    ///   - content: Builder invoked with the decoded `Image` once available.
    ///     Apply `resizable()`, `scaledToFill()`, and any other styling here.
    ///   - placeholder: Builder invoked while the image is unavailable
    ///     (either still loading, or the URL was `nil`).
    public init(
        url: URL?,
        cache: any ImageCacheStore,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.explicitCache = cache
        self.content = content
        self.placeholder = placeholder
    }

    /// Creates a cached async image view using the environment cache.
    ///
    /// Requires that an `ImageCacheStore` has been injected into the
    /// environment via `.imageCache(_:)` on an ancestor view. If no cache is
    /// available, the placeholder is shown permanently.
    ///
    /// - Parameters:
    ///   - url: The image URL. Pass `nil` to leave the placeholder showing.
    ///   - content: Builder invoked with the decoded `Image` once available.
    ///   - placeholder: Builder invoked while the image is unavailable.
    public init(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.url = url
        self.explicitCache = nil
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let displayedImage {
                content(displayedImage)
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage()
        }
    }

    private var displayedImage: Image? {
        if loadedURL == url, let image {
            return image
        }
        guard let url, let cached = Self.decodedImage(for: url) else { return nil }
        return Image(platformImage: cached)
    }

    private func loadImage() async {
        guard let url else {
            image = nil
            loadedURL = nil
            return
        }
        if loadedURL == url, image != nil { return }

        if let cached = Self.decodedImage(for: url) {
            image = Image(platformImage: cached)
            loadedURL = url
            return
        }

        image = nil
        loadedURL = nil

        guard let cache = resolvedCache else { return }

        do {
            let data = try await cache.imageData(for: url)
            guard !Task.isCancelled else { return }
            guard let decoded = PlatformImage(data: data) else {
                try? await cache.removeValue(for: url)
                Self.logger.error(
                    "Cached image data could not decode for \(url.absoluteString, privacy: .public)"
                )
                return
            }
            Self.storeDecodedImage(decoded, for: url)
            image = Image(platformImage: decoded)
            loadedURL = url
        } catch {
            Self.logger.error(
                "Failed to load cached image for \(url.absoluteString, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
        }
    }
}

// MARK: - Decoded-image cache

extension CachedAsyncImage {

    fileprivate static func decodedImage(for url: URL) -> PlatformImage? {
        DecodedImageCache.shared.object(forKey: url as NSURL)
    }

    fileprivate static func storeDecodedImage(_ image: PlatformImage, for url: URL) {
        DecodedImageCache.shared.setObject(image, forKey: url as NSURL)
    }
}

private enum DecodedImageCache {
    /// NSCache is documented as thread-safe; the type itself isn't
    /// `Sendable`-annotated, hence the `nonisolated(unsafe)` opt-out.
    nonisolated(unsafe) static let shared: NSCache<NSURL, PlatformImage> = {
        let cache = NSCache<NSURL, PlatformImage>()
        cache.countLimit = 200
        return cache
    }()
}

// MARK: - Platform image bridging

extension Image {
    fileprivate init(platformImage: PlatformImage) {
        #if canImport(UIKit)
            self.init(uiImage: platformImage)
        #elseif canImport(AppKit)
            self.init(nsImage: platformImage)
        #endif
    }
}
