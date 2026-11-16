
import SwiftUI
import CoreText
import UIKit

extension Emotion {

    /// The vivid tone: the background glow, and anything drawn on a photo or black surface
    /// (route on the run photo, intensity dots, turn arrow tile, landing logo).
    /// Too light for lines on the light screen; use `ink` there.
    var color: Color {
        switch self {
        case .angry:
            return Color(hex: "#FC4540")
        case .stressed:
            return Color(hex: "#44BCF2")
        case .anxious:
            // Deliberately the full neon green: anxious should feel sharp, not soothing.
            return Color(hex: "#00FF00")
        case .tired:
            return Color(hex: "#909CF5")
        case .happy:
            return Color(hex: "#FFD60A")
        }
    }

    /// The deep tone for lines, dots and icons on the light screen (AfterRun route, Running route
    /// progress and position dot). Each keeps at least 3:1 contrast over the glow-tinted background.
    var ink: Color {
        switch self {
        case .angry:
            return Color(hex: "#C51E21")
        case .stressed:
            return Color(hex: "#006EAD")
        case .anxious:
            return Color(hex: "#007F3D")
        case .tired:
            return Color(hex: "#504FC6")
        case .happy:
            // A dark yellow reads as brown, so happy's ink shifts to tangerine instead.
            return Color(hex: "#D96400")
        }
    }
}

extension Emotion {
    /// Top of the soft fill under the intensity graph line; fades to clear below.
    var graphFill: Color { color.opacity(0.35) }
    /// Top of the color curtain under the 3D route; fades to clear below.
    var routeCurtain: Color { color.opacity(0.7) }
}

// MARK: - The big word on the Home screen (Figma frames iPhone 16 - 153 to 190)

extension Emotion {
    /// The word as the Home screen writes it: each emotion has its own casing.
    var wordText: String {
        switch self {
        case .angry: return "ANGRY"
        case .stressed: return "stressed"
        case .anxious: return "Anxious"
        case .tired: return "Tired"
        case .happy: return "HAPPY"
        }
    }

    /// Each emotion's own typeface (Google Fonts, bundled in `Animo/Fonts`; Angry uses SF Pro Expanded Black).
    var wordFont: Font {
        switch self {
        case .angry: return .system(size: 48, weight: .black).width(.expanded)
        case .stressed: return .custom("Knewave-Regular", size: 48)
        case .anxious: return .custom("RockSalt-Regular", size: 48)
        case .tired: return .custom("ReenieBeanie", size: 64)
        case .happy: return .custom("Modak", size: 64)
        }
    }

    /// Letter spacing from the design (-3% of the size, -4% for Stressed).
    var wordTracking: CGFloat {
        switch self {
        case .angry, .anxious: return -1.44
        case .stressed: return -1.92
        case .tired, .happy: return -1.92
        }
    }

    /// The pure, saturated tone the word is drawn in.
    var wordColor: Color {
        switch self {
        case .angry: return Color(hex: "#FF0000")
        case .stressed: return Color(hex: "#00AEEF")
        case .anxious: return Color(hex: "#00FF00")
        case .tired: return Color(hex: "#7A8BFF")
        case .happy: return Color(hex: "#EBEB15")
        }
    }
}

extension Emotion {
    /// Where the word's ink actually sits, so it can be centered by what you see instead of by its text box
    /// (each font's box has different space above and below its letters, and some letters hang past the end).
    /// `ink` is relative to the baseline start (y up); `ascender` is how far the baseline sits below the box's top.
    var wordInkMetrics: (ink: CGRect, ascender: CGFloat) {
        let font: UIFont
        switch self {
        case .angry: font = UIFont.systemFont(ofSize: 48, weight: .black, width: .expanded)
        case .stressed: font = UIFont(name: "Knewave-Regular", size: 48) ?? .systemFont(ofSize: 48)
        case .anxious: font = UIFont(name: "RockSalt-Regular", size: 48) ?? .systemFont(ofSize: 48)
        case .tired: font = UIFont(name: "ReenieBeanie", size: 64) ?? .systemFont(ofSize: 64)
        case .happy: font = UIFont(name: "Modak", size: 64) ?? .systemFont(ofSize: 64)
        }
        let attributed = NSAttributedString(string: wordText, attributes: [.font: font, .kern: wordTracking])
        let line = CTLineCreateWithAttributedString(attributed)
        let ink = CTLineGetBoundsWithOptions(line, .useGlyphPathBounds)
        return (ink, font.ascender)
    }
}
