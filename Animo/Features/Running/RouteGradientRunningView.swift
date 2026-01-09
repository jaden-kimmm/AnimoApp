
import SwiftUI

struct RouteGradientRunningView: View {
    let emotion: Emotion

    private var runningStrokeGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(stops: [
                .init(color: emotion.color.opacity(0.10), location: 0.00),
                .init(color: emotion.color,               location: 0.00),
                .init(color: emotion.color,               location: 0.57),
                .init(color: emotion.color.opacity(0.10), location: 0.57)
            ]),
            center: .center
        )
    }

    var body: some View {
        GeometryReader { geo in
            let designSide: CGFloat = 1000
            let side = min(geo.size.width, geo.size.height)
            let scale = side / designSide

            ZStack {
                emotion.color
                    .mask(
                        Image("route1_fill")
                            .resizable()
                            .scaledToFit()
                    )
                    .opacity(0.10)

                runningStrokeGradient
                    .rotationEffect(.degrees(90))
                    .mask(
                        Image("route1_stroke")
                            .resizable()
                            .scaledToFit()
                    )

                GeometryReader { innerGeo in
                    let nx: CGFloat = 0.64
                    let ny: CGFloat = 0.22

                    Circle()
                        .fill(emotion.color)
                        .frame(width: 50, height: 50)
                        .position(
                            x: innerGeo.size.width * nx,
                            y: innerGeo.size.height * ny
                        )
                }
            }
            .frame(width: designSide, height: designSide)
            .scaleEffect(scale)
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
        .aspectRatio(1, contentMode: .fit)
        .compositingGroup()
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        RouteGradientRunningView(emotion: .stressed)
            .padding(40)
    }
}
