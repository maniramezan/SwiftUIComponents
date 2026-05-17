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

- ``Motion``
- ``DefaultMotion``

### State

- ``LoadingState``

### Caching

- ``ImageCacheStore``
