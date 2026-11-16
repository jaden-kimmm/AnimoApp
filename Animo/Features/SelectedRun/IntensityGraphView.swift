import SwiftUI

/// The planned effort over the run: a smooth line in the emotion's color with a soft fill fading down
/// beneath it. Sits on the run photo on the Selected Run screen.
struct IntensityGraphView: View {
    let emotion: Emotion
    /// Effort for each stretch of the run, 1 (easy) to 9 (hard), start to finish. Taken from the old dot graph.
    var levels: [Double] = [5, 6, 8, 5, 4, 4, 3, 4, 2, 3, 3, 2, 2, 4, 5, 4, 3, 3, 2, 2, 4, 5, 3, 2, 4, 1, 3, 8, 9, 8, 6]

    @State private var drawn: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            IntensityCurve(levels: levels, closed: true)
                .fill(LinearGradient(colors: [emotion.graphFill, .clear], startPoint: .top, endPoint: .bottom))
                .opacity(Double(drawn))

            IntensityCurve(levels: levels, closed: false)
                .trim(from: 0, to: drawn)
                .stroke(emotion.color, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
        }
        .aspectRatio(3.6, contentMode: .fit)
        .onAppear {
            if reduceMotion { drawn = 1 } else { withAnimation(.easeOut(duration: 1.1)) { drawn = 1 } }
        }
        .accessibilityElement()
        .accessibilityLabel("Intensity")
        .accessibilityValue("Starts moderate, stays easy through the middle, and builds to a hard finish")
    }
}

/// The intensity line. With `closed`, the area under it down to the bottom edge, for the fill.
private struct IntensityCurve: Shape {
    let levels: [Double]
    let closed: Bool

    func path(in rect: CGRect) -> Path {
        guard levels.count > 1, let top = levels.max() else { return Path() }
        let inset: CGFloat = 2   // keeps the stroke inside the frame
        let points = levels.enumerated().map { i, v in
            CGPoint(x: rect.minX + rect.width * CGFloat(i) / CGFloat(levels.count - 1),
                    y: rect.maxY - inset - (rect.height - inset * 2) * CGFloat(v / top))
        }
        var p = Path()
        p.move(to: points[0])
        // Each step bends horizontally out of one point and into the next: smooth, and never overshoots a peak.
        for (a, b) in zip(points, points.dropFirst()) {
            let midX = (a.x + b.x) / 2
            p.addCurve(to: b, control1: CGPoint(x: midX, y: a.y), control2: CGPoint(x: midX, y: b.y))
        }
        if closed {
            p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            p.closeSubpath()
        }
        return p
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        IntensityGraphView(emotion: .stressed)
            .padding(40)
    }
}
