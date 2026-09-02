import Components
import DesignSystem
import SwiftUI

struct GhostLoadingDetailView: View {
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var sweepEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Controls") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Toggle("Sweep highlight", isOn: $sweepEnabled)
                        .toggleStyle(ThemeToggleStyle())
                    Text(
                        "The toggle drives `\\.isGhostShimmerDisabled` — the same environment "
                            + "value snapshot tests set to freeze the clock-driven sweep."
                    )
                    .designTextStyle(.secondary)
                    Text(
                        reduceMotion
                            ? "Reduce Motion is on — the sweep is suppressed regardless of the toggle."
                            : "Turn on Reduce Motion in system settings to see the sweep fall back to a static skeleton."
                    )
                    .designTextStyle(.secondary)
                }
            }

            VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
                ShowcaseSection("Article card skeleton") {
                    VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                        GhostLoadingBlock(width: 120, height: 12)
                        GhostLoadingBlock(height: 20)
                        GhostLoadingBlock(height: 16)
                        GhostLoadingBlock(width: 200, height: 16)
                        GhostLoadingBlock(height: 100, cornerRadius: theme.radius.oneAndHalfUnits)
                    }
                    .accessibilityLabel("Loading")
                }

                ShowcaseSection("Profile row skeleton") {
                    HStack(spacing: theme.spacing.oneAndHalfUnits) {
                        GhostLoadingBlock(
                            width: theme.spacing.sixUnits,
                            height: theme.spacing.sixUnits,
                            cornerRadius: theme.radius.threeUnits
                        )
                        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
                            GhostLoadingBlock(width: 140, height: 14)
                            GhostLoadingBlock(width: 90, height: 12)
                        }
                    }
                    .accessibilityLabel("Loading")
                }
            }
            .designGhostShimmer()
            .environment(\.isGhostShimmerDisabled, !sweepEnabled)

            ShowcaseSection("Overlay & interactive role tokens") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    RoleSwatch("interactiveSubtle", color: theme.colors.interactiveSubtle)
                    RoleSwatch("overlaySubtle", color: theme.colors.overlaySubtle)
                    RoleSwatch("overlayMedium", color: theme.colors.overlayMedium, onColor: theme.colors.onOverlay)
                    RoleSwatch("overlayHeavy", color: theme.colors.overlayHeavy, onColor: theme.colors.onOverlay)
                    RoleSwatch("shimmerHighlight", color: theme.colors.shimmerHighlight)
                    LinearGradient(
                        colors: [theme.colors.overlayShadowStart, theme.colors.overlayShadowEnd],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: theme.spacing.fourUnits)
                    .clipShape(RoundedRectangle(cornerRadius: theme.radius.oneUnit, style: .continuous))
                    .overlay(alignment: .leading) {
                        Text("overlayShadowStart → overlayShadowEnd")
                            .designTextStyle(.caption)
                            .padding(.leading, theme.spacing.oneUnit)
                    }
                }
            }
        }
    }
}

/// A labelled colour chip for a single `ColorTheme` role token.
private struct RoleSwatch: View {
    let name: String
    let color: Color
    var onColor: Color?
    @Environment(\.designTheme) private var theme

    init(_ name: String, color: Color, onColor: Color? = nil) {
        self.name = name
        self.color = color
        self.onColor = onColor
    }

    var body: some View {
        HStack(spacing: theme.spacing.oneUnit) {
            RoundedRectangle(cornerRadius: theme.radius.oneUnit, style: .continuous)
                .fill(color)
                .frame(width: theme.spacing.sixUnits, height: theme.spacing.fourUnits)
                .overlay {
                    if let onColor {
                        Text("Aa")
                            .font(theme.typography.caption)
                            .foregroundStyle(onColor)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius.oneUnit, style: .continuous)
                        .stroke(theme.colors.border, lineWidth: 1)
                }
            Text(name)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
        }
    }
}

#Preview {
    ScrollView {
        GhostLoadingDetailView()
            .padding()
    }
}
