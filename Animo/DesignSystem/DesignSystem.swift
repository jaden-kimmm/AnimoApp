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

enum AppColor {
    static let white = Color(hex: "#ffffff")
    static let black = Color(hex: "#000000")
    static let bg = Color(hex: "#F7F7F7")
    static let blackText = Color(hex: "#000000")
    static let whiteText = Color(hex: "#666666")
    static let lightWhiteText = Color(hex: "#7C7C7C")
}

enum TextStyle {
    case display
    case headline
    case body
    case label

    private static let regular = "OverusedGrotesk-Roman"
    private static let book = "OverusedGrotesk-Book"

    var font: Font {
        switch self {
        case .display: return .custom(Self.regular, size: 48)
        case .headline: return .custom(Self.regular, size: 24)
        case .body: return .custom(Self.book, size: 16)
        case .label: return .custom(Self.book, size: 14)
        }
    }

    var tracking: CGFloat {
        switch self {
        case .display: return -0.48
        case .headline: return -0.48
        case .body: return 0
        case .label: return 0
        }
    }
}

extension Text {
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .tracking(style.tracking)
    }
}
