import SwiftUI

// MARK: - Route shapes

/// The sample routes. Each one is a closed outline stored as path data (`RouteData.swift`), so it
/// draws crisply at any size and can be filled, stroked, trimmed and measured like any other `Shape`.
enum RouteShape: CaseIterable {
    case route1, route2, route3, route4, route5

    private var commands: [RouteCommand] {
        switch self {
        case .route1: return RouteData.route1
        case .route2: return RouteData.route2
        case .route3: return RouteData.route3
        case .route4: return RouteData.route4
        case .route5: return RouteData.route5
        }
    }

    /// The outline in its own design units (y down), before any scaling.
    fileprivate var rawPath: Path {
        var p = Path()
        for command in commands {
            switch command {
            case let .move(x, y): p.move(to: CGPoint(x: x, y: y))
            case let .line(x, y): p.addLine(to: CGPoint(x: x, y: y))
            case let .curve(c1x, c1y, c2x, c2y, x, y):
                p.addCurve(
                    to: CGPoint(x: x, y: y),
                    control1: CGPoint(x: c1x, y: c1y),
                    control2: CGPoint(x: c2x, y: c2y)
                )
            case .close: p.closeSubpath()
            }
        }
        return p
    }

    /// The outline in its own design units, for views that draw it their own way (Route3DView).
    var outline: Path { rawPath }

    /// Width / height of the drawn outline.
    var aspectRatio: CGFloat {
        let b = rawPath.boundingRect
        return b.height > 0 ? b.width / b.height : 1
    }
}

/// A route scaled to fit (and centered in) its rect, keeping its proportions. `inset` keeps a thick
/// stroke from poking outside the rect.
struct RouteOutline: Shape {
    let route: RouteShape
    var inset: CGFloat = 0

    func path(in rect: CGRect) -> Path {
        let raw = route.rawPath
        let bounds = raw.boundingRect
        let area = rect.insetBy(dx: inset, dy: inset)
        guard bounds.width > 0, bounds.height > 0, area.width > 0, area.height > 0 else { return raw }

        let scale = min(area.width / bounds.width, area.height / bounds.height)
        let transform = CGAffineTransform(translationX: area.midX, y: area.midY)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -bounds.midX, y: -bounds.midY)
        return raw.applying(transform)
    }
}

// MARK: - Route view

/// An emotion-colored route. Fills its available space and keeps the route's proportions, so it is
/// never cropped (the old image-mask versions clipped routes that were wider than their frame).
struct RouteView: View {
    enum Style {
        /// Soft fill with a solid outline in the emotion's color (Echo Park Run, Latest Runs cards, Run Complete).
        case fill
        /// Outline in the emotion's color for the part already run (0...1), a faint one for the rest, and a dot at
        /// the runner's position (Running).
        case progress(Double)
    }

    let emotion: Emotion
    var route: RouteShape = .route1
    var style: Style = .fill

    var body: some View {
        GeometryReader { geo in
            let drawnWidth = min(geo.size.width, geo.size.height * route.aspectRatio)
            let lineWidth = max(1.5, drawnWidth * 0.0105)
            let outline = RouteOutline(route: route, inset: lineWidth / 2)
            let lineStyle = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)

            ZStack {
                outline.fill(emotion.color.opacity(0.10))

                switch style {
                case .fill:
                    outline.stroke(emotion.color, style: lineStyle)

                case .progress(let done):
                    let done = min(max(done, 0), 1)
                    outline.stroke(AppColor.routeRemaining, style: lineStyle)
                    // Counting back from the end of the outline sweeps the finished part clockwise from
                    // the bottom, the way the route reads on screen.
                    outline.trim(from: 1 - done, to: 1).stroke(emotion.color, style: lineStyle)

                    let rect = CGRect(origin: .zero, size: geo.size)
                    let position = outline.path(in: rect).trimmedPath(from: 0, to: 1 - done).currentPoint
                    if let position {
                        Circle()
                            .fill(emotion.color)
                            .frame(width: drawnWidth * 0.05, height: drawnWidth * 0.05)
                            .position(position)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview("All routes") {
    ZStack {
        AppColor.bg.ignoresSafeArea()
        VStack(spacing: 16) {
            ForEach(Array(zip(RouteShape.allCases, Emotion.allCases)), id: \.0) { route, emotion in
                RouteView(emotion: emotion, route: route, style: .fill)
                    .frame(height: 110)
            }
        }
        .padding(24)
    }
}

#Preview("Progress") {
    ZStack {
        AppColor.bg.ignoresSafeArea()
        RouteView(emotion: .stressed, route: .route1, style: .progress(0.57))
            .frame(height: 320)
            .padding(24)
    }
}
