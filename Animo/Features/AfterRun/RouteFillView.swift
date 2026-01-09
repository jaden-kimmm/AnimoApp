
import SwiftUI


struct RouteFillView: View {
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

            emotion.color
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
        RouteFillView(emotion: .stressed, route: .route1)
            .padding(40)
    }
}
