# ``DesignSystem``

A platform-agnostic design token layer providing spacing, radius, stroke, motion, color, and typography primitives.

## Overview

`DesignSystem` defines protocols and default implementations for every visual token a UI component might need. Inject a custom ``Theme`` via the SwiftUI environment to rebrand the entire component library without changing component source code.

## Topics

### Theme

- ``Theme``
- ``DefaultTheme``

### Colors

- ``ColorTheme``
- ``DefaultColors``

### Typography

Custom ``Typography`` conformers supply the native `controlUIFont` on UIKit or `controlNSFont`
on AppKit in addition to SwiftUI fonts. These requirements dispatch through the theme protocol.
``DefaultTypography`` uses its configured family for native picker triggers as well as SwiftUI text.


- ``Typography``
- ``DefaultTypography``

### Layout

- ``Spacing``
- ``DefaultSpacing``
- ``Radius``
- ``DefaultRadius``
- ``Stroke``
- ``DefaultStroke``

### Motion

- ``Motion/orbitalRevolutionDuration``
- ``Motion``
- ``DefaultMotion``
- ``MotionSpring``

### State

- ``LoadingState``
- ``AsyncLoadable``

### Caching

``ImageCacheStore`` requires reference identity and `Sendable` conformance. An actor is a natural
owner for cached image bytes. Retain a store while it remains authoritative; replacing it at the
same URL starts a new request in `Components.CachedAsyncImage`. There is no package-global decoded cache.


- ``ImageCacheStore``
