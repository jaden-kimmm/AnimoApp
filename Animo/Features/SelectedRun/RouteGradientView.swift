
import SwiftUI

enum RouteShape {
    case route1
    case route2
    case route3
    case route4
    case route5

    var fillAssetName: String {
        switch self {
        case .route1: return "route1_fill"
        case .route2: return "route2_fill"
        case .route3: return "route3_fill"
        case .route4: return "route4_fill"
        case .route5: return "route5_fill"
        }
    }

    var strokeAssetName: String {
        switch self {
        case .route1: return "route1_stroke"
        case .route2: return "route2_stroke"
        case .route3: return "route3_stroke"
        case .route4: return "route4_stroke"
        case .route5: return "route5_stroke"
        }
    }
}

struct RouteGradientView: View {
    let emotion: Emotion
    let route: RouteShape

    private let maskScale: CGFloat = 0.89

    var body: some View {
        ZStack {
            emotion.color
                .mask(
                    Image(route.fillAssetName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(maskScale)
                        
                )
                .opacity(0.10)

            emotion.angularGradient
                .rotationEffect(.degrees(90))
                .mask(
                    Image(route.strokeAssetName)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(maskScale)
                        
                )
        }
        .compositingGroup()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RouteGradientView(emotion: .stressed, route: .route1)
            .padding(40)
    }
}
