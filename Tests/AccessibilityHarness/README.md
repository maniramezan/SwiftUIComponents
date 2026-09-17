# Chat accessibility regression

This neutral app verifies the actual iOS accessibility tree. A hostless SwiftUI
unit-test process can expose an empty accessibility tree even after laying out a
hosting view, so construction/rendering tests cannot establish this behavior.

From this directory, run `xcodegen generate`, then:

```sh
xcodebuild test -scheme ChatAccessibility -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -collect-test-diagnostics never
```

The test must find the message text beneath the speaker group. Replacing `.contain`
with `.combine` while retaining the explicit speaker label hides that text.

Apple's [container behavior documentation](https://developer.apple.com/documentation/swiftui/accessibilitychildbehavior/contain)
explains why the speaker label belongs on a container that preserves its children.
