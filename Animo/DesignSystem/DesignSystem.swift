import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

/// Layout constants shared across screens.
enum AppSpacing {
    /// Left, right and bottom margin for every screen's content (buttons, text, images).
    static let screenMargin: CGFloat = 24
}

/// The app's color tokens. Views should use these instead of raw `Color.white` / `Color.black`
/// or ad-hoc `.opacity(...)` values, so a color change is one edit here.
/// Emotion accents live separately on `Emotion.color` (Emotion+Style.swift).
enum AppColor {

    // MARK: Palette

    static let white = Color(hex: "#FCFCFC")
    static let black = Color(hex: "#111111")
    /// App background.
    static let bg = Color(hex: "#F7F7F7")

    // MARK: Text

    /// Primary text on light surfaces.
    static let textPrimary = black
    /// Secondary text: labels, captions, unselected tabs.
    static let textSecondary = Color(hex: "#7C7C7C")
    /// Text on black, photo, or dark-glass surfaces.
    static let textOnDark = white
    /// Secondary text on dark surfaces.
    static let textOnDarkMuted = white.opacity(0.5)

    // MARK: Lines

    /// Divider between settings rows.
    static let separator = textSecondary.opacity(0.22)
    /// Thin rule between info rows (SelectedRun).
    static let hairline = black.opacity(0.08)
    /// The not-yet-run portion of the route on the Running screen.
    static let routeRemaining = black.opacity(0.15)

    // MARK: Overlays

    /// Washes a photo background so black text stays readable (SelectedRun, AfterRun).
    static let scrimLight = white.opacity(0.3)
    /// Faint wash over the Running screen's photo background.
    static let scrimLightSoft = white.opacity(0.15)
    /// Darkens card photos behind white text.
    static let scrimDark = black.opacity(0.18)
    /// Darkens a selected pill's photo behind its white label.
    static let scrimDarkSoft = black.opacity(0.15)
    /// Deepest point of the darkening under text that sits on a full-bleed photo (Run Detail).
    static let scrimDarkStrong = black.opacity(0.5)
    /// Tint for light liquid-glass controls.
    static let glassTintLight = white.opacity(0.6)
    /// Faint white wash for clear glass that should stay see-through but read a little whiter.
    static let glassTintSoft = white.opacity(0.5)
    /// Strong white tint: glass that reads as nearly white but still refracts (welcome logo and Start button).
    static let glassTintWhite = white.opacity(0.85)
    /// Dark, smoky tint for glass that sits on photos (stat bars); keeps white text readable without turning the glass white.
    static let glassTintDark = black.opacity(0.28)
    /// Drop shadow under the white button.
    static let shadow = black.opacity(0.25)
    /// Soft shadow under each glass dot of the welcome ring.
    static let dotShadow = black.opacity(0.4)
}

enum TextStyle {
    case display
    case headline
    case body
    case label
    /// Text inside buttons (17pt, matching the system Body size used by Parallel's buttons).
    case button

    private static let regular = "OverusedGrotesk-Roman"
    private static let book = "OverusedGrotesk-Book"

    var font: Font {
        switch self {
        case .display: return .custom(Self.regular, size: 48)
        case .headline: return .custom(Self.regular, size: 24)
        case .body: return .custom(Self.book, size: 16)
        case .label: return .custom(Self.book, size: 14)
        case .button: return .custom(Self.book, size: 17)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .display: return -1.44
        case .headline: return -0.48
        case .body: return 0
        case .label: return 0
        case .button: return 0
        }
    }

    /// Line height from the Figma text style, where the design specifies one.
    var designLineHeight: CGFloat? {
        switch self {
        case .display: return 48
        case .headline: return nil
        case .body: return 20
        case .label: return 18
        case .button: return nil
        }
    }

    /// Opt-in: pass to `.lineSpacing(_:)` on multi-line text to match the design's line height.
    /// SwiftUI uses the font's own (taller) line height by default; this closes the difference.
    var designLineSpacing: CGFloat {
        guard let designLineHeight else { return 0 }
        let (name, size): (String, CGFloat) = {
            switch self {
            case .display: return (Self.regular, 48)
            case .headline: return (Self.regular, 24)
            case .body: return (Self.book, 16)
            case .label: return (Self.book, 14)
            case .button: return (Self.book, 17)
            }
        }()
        guard let natural = UIFont(name: name, size: size)?.lineHeight else { return 0 }
        return designLineHeight - natural
    }
}

extension Text {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
    }
}
