import Components
import DesignSystem
import SwiftUI

struct CachedAsyncImageDetailView: View {
    @State private var source = "first"
    @State private var usesCache = true
    @State private var usesAlternateStore = false
    @State private var usesExplicitStore = false
    @State private var side = 100.0
    @State private var firstStore = ShowcaseImageStore(symbol: "star.fill")
    @State private var secondStore = ShowcaseImageStore(symbol: "circle.fill")
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Image") {
                ShowcaseCachedImage(
                    url: source == "none" ? nil : URL(string: "https://example.com/\(source)"),
                    store: usesAlternateStore ? secondStore : firstStore,
                    explicit: usesExplicitStore
                )
                .environment(\.imageCache, usesCache ? (usesAlternateStore ? secondStore : firstStore) : nil)
                .frame(width: side, height: side)
            }
            ShowcaseSection("Controls") {
                Picker("Source", selection: $source) {
                    Text("First image").tag("first")
                    Text("Second image").tag("second")
                    Text("Invalid bytes").tag("invalid")
                    Text("Failure").tag("failure")
                    Text("No URL").tag("none")
                }
                Toggle("Provide environment store", isOn: $usesCache)
                Toggle("Use explicit store", isOn: $usesExplicitStore)
                Toggle("Replace store at the same URL", isOn: $usesAlternateStore)
                LabeledContent("Size") { Slider(value: $side, in: 44...200) }
                Text("Images are generated locally; loading simulates a short delay.")
                    .designTextStyle(.caption)
            }
        }
    }
}

private struct ShowcaseCachedImage: View {
    let url: URL?
    let store: ShowcaseImageStore
    let explicit: Bool

    var body: some View {
        if explicit {
            CachedAsyncImage(url: url, cache: store) {
                $0.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
        } else {
            CachedAsyncImage(url: url) {
                $0.resizable().scaledToFit()
            } placeholder: {
                ProgressView()
            }
        }
    }
}

private actor ShowcaseImageStore: ImageCacheStore {
    let symbol: String
    private var data: [URL: Data] = [:]

    init(symbol: String) { self.symbol = symbol }

    func imageData(for url: URL) async throws -> Data {
        if let cached = data[url] { return cached }
        try await Task.sleep(for: .milliseconds(300))
        if url.lastPathComponent == "failure" { throw ImageError.unavailable }
        if url.lastPathComponent == "invalid" { return Data() }
        let symbol = url.lastPathComponent == "second" ? "square.fill" : symbol
        let rendered = await MainActor.run {
            let renderer = ImageRenderer(content: Image(systemName: symbol).resizable().frame(width: 100, height: 100))
            #if canImport(UIKit)
                return renderer.uiImage?.pngData() ?? Data()
            #elseif canImport(AppKit)
                guard let tiff = renderer.nsImage?.tiffRepresentation,
                    let bitmap = NSBitmapImageRep(data: tiff)
                else { return Data() }
                return bitmap.representation(using: .png, properties: [:]) ?? Data()
            #endif
        }
        data[url] = rendered
        return rendered
    }

    func removeValue(for url: URL) async throws { data[url] = nil }
    private enum ImageError: Error { case unavailable }
}
