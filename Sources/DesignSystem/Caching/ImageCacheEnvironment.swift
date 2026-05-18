import SwiftUI

private struct ImageCacheStoreKey: EnvironmentKey {
    static let defaultValue: (any ImageCacheStore)? = nil
}

public extension EnvironmentValues {
    /// The shared image cache available to `CachedAsyncImage` views in this
    /// hierarchy. When set, views can omit the explicit `cache:` parameter.
    var imageCache: (any ImageCacheStore)? {
        get { self[ImageCacheStoreKey.self] }
        set { self[ImageCacheStoreKey.self] = newValue }
    }
}

public extension View {
    /// Injects a shared image cache for all `CachedAsyncImage` views in this
    /// hierarchy.
    ///
    /// ```swift
    /// ContentView()
    ///     .imageCache(MyAppImageCache.shared)
    /// ```
    func imageCache(_ cache: any ImageCacheStore) -> some View {
        environment(\.imageCache, cache)
    }
}
