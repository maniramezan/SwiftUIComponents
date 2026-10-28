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
/// The supplied store owns caching policy. The view retains only its current decoded
/// image; it never shares decoded results between stores. A request consists of the
/// URL and the store's reference identity. Replacing either restarts loading.
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

    @State private var loader = CachedImageLoader()
    @Environment(\.imageCache) private var environmentCache

    private var resolvedCache: (any ImageCacheStore)? {
        explicitCache ?? environmentCache
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

    /// Displays the current request's decoded image or its placeholder.
    public var body: some View {
        let cache = resolvedCache
        let request = CachedImageRequest(url: url, cache: cache)
        Group {
            if loader.request == request, let image = loader.image {
                content(image)
            } else {
                placeholder()
            }
        }
        .task(id: request) {
            await loader.load(url: url, cache: cache)
        }
    }
}

struct CachedImageRequest: Equatable {
    let url: URL?
    let storeID: ObjectIdentifier?

    init(url: URL?, cache: (any ImageCacheStore)?) {
        self.url = url
        self.storeID = cache.map(ObjectIdentifier.init)
    }
}

@MainActor
@Observable
final class CachedImageLoader {
    private(set) var image: Image?
    private(set) var request: CachedImageRequest?
    private var store: (any ImageCacheStore)?
    private static let logger = Logger(subsystem: "com.swiftuicomponents", category: "CachedAsyncImage")

    func load(url: URL?, cache: (any ImageCacheStore)?) async {
        let incoming = CachedImageRequest(url: url, cache: cache)
        if request == incoming, image != nil { return }
        request = incoming
        store = cache
        image = nil
        guard let url, let cache else { return }
        do {
            let data = try await cache.imageData(for: url)
            guard !Task.isCancelled, request == incoming else { return }
            guard let decoded = PlatformImage(data: data) else {
                try? await cache.removeValue(for: url)
                Self.logger.error("Cached image data could not decode")
                return
            }
            image = Image(platformImage: decoded)
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled, request == incoming else { return }
            Self.logger.error("Failed to load cached image: \(error.localizedDescription, privacy: .public)")
        }
    }
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
