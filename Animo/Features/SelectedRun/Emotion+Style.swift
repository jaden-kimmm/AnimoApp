
import SwiftUI

extension Emotion {

    var color: Color {
        switch self {
        case .angry:
            return Color(hex: "#FF0000")
        case .stressed:
            return Color(hex: "#00AEEF")
        case .anxious:
            return Color(hex: "#00FF00")
        case .tired:
            return Color(hex: "#7A8BFF")
        case .happy:
            return Color(hex: "#F4F400")
        }
    }

    var angularGradient: AngularGradient {
        AngularGradient(
            stops: [
                .init(color: self.color, location: 0.0),
                .init(color: .white, location: 1.0)
            ],
            center: .center
        )
    }
}
