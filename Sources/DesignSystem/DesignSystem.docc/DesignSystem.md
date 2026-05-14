# ``DesignSystem``

A platform-agnostic design token layer providing spacing, radius, stroke, motion, color, and typography primitives.

## Overview

`DesignSystem` defines protocols and default implementations for every visual token a UI component might need. Inject a custom ``DesignTheme`` via the SwiftUI environment to rebrand the entire component library without changing component source code.

## Topics

### Theme

- ``DesignTheme``
- ``DefaultDesignTheme``

### Colors

- ``DesignColorTheme``
- ``DefaultDesignColors``

### Typography

- ``DesignTypography``
- ``DefaultDesignTypography``

### Layout

- ``DesignSpacing``
- ``DefaultDesignSpacing``
- ``DesignRadius``
- ``DefaultDesignRadius``
- ``DesignStroke``
- ``DefaultDesignStroke``

### Motion

- ``DesignMotion``
- ``DefaultDesignMotion``
