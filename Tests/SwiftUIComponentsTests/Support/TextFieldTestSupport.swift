#if canImport(AppKit)
    import AppKit
    import Testing

    @MainActor
    func editableTextField(in view: NSView) -> NSTextField? {
        if let field = view as? NSTextField, field.isEditable {
            return field
        }
        return view.subviews.lazy.compactMap { editableTextField(in: $0) }.first
    }

    @MainActor
    func replaceText(_ text: String, in field: NSTextField, window: NSWindow) throws {
        window.makeFirstResponder(field)
        let editor = try #require(field.currentEditor() as? NSTextView)
        editor.insertText(text, replacementRange: NSRange(location: 0, length: editor.string.utf16.count))
    }
#endif
