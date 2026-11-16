import SwiftUI

/// A route that tips into 3D as you tilt the phone. Held as you picked it up, it reads as the flat map.
/// Tilt the phone and the loop slowly lays back onto the ground, turns a little, and a soft curtain of the
/// emotion's color drops from the line to the ground, taller where the run climbs.
///
/// There is no 3D engine here: every point is projected by hand and drawn in one Canvas. The curtain is one
/// short wall per segment, drawn far to near so the walls in front cover the ones behind.
struct Route3DView: View {
    let emotion: Emotion
    var route: RouteShape = .route1

    /// How much phone tilt (radians) it takes to reach the full 3D view. Only tilting the phone up counts;
    /// tilting it down leaves the flat map alone.
    var tiltForFull3D: Double = 0.4
    /// Which way counts as "up" for the phone's pitch (checked on a phone: -1 is tilting the phone up).
    private let upSign: Double = -1
    /// The full 3D view: how far the ground lays back (radians; pi/2 is the flat map from straight above)
    /// and how far the loop turns.
    var pitch3D: Double = 0.8
    var yaw3D: Double = -0.3
    var lineWidth: CGFloat = 4
    /// Always show the full 3D view, ignoring tilt (the live Running screen).
    var alwaysIn3D = false
    /// The share of the route already run (0...1); a dot marks where the runner is. Nil draws no dot.
    var progress: Double? = nil

    @State private var tilt = TiltModel()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(paused: reduceMotion || alwaysIn3D)) { _ in
                let scene = RouteScene.make(route: route, size: geo.size, amount: amount,
                                            pitch3D: pitch3D, yaw3D: yaw3D, onlyFull3D: alwaysIn3D)
                Canvas { context, _ in draw(scene, in: &context) }
            }
        }
        .aspectRatio(RouteScene.aspect(for: route, pitch3D: pitch3D, yaw3D: yaw3D, onlyFull3D: alwaysIn3D),
                     contentMode: .fit)
        .onAppear { if !reduceMotion && !alwaysIn3D { tilt.start() } }
        .onDisappear { tilt.stop() }
        #if targetEnvironment(simulator)
        // The Simulator can't tilt: drag up on the route to stand in for tilting the phone up.
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { tilt.setTarget(roll: 0, pitch: -Double($0.translation.height / 150) * tiltForFull3D * upSign) }
                .onEnded { _ in tilt.setTarget(roll: 0, pitch: 0) }
        )
        #endif
        .accessibilityElement()
        .accessibilityLabel("Route")
    }

    /// 0 = flat map, 1 = full 3D, eased so it starts and settles gently.
    private var amount: Double {
        if alwaysIn3D { return 1 }
        guard !reduceMotion else { return 0 }
        tilt.step()
        let t = min(max(tilt.pitch * upSign / tiltForFull3D, 0), 1)
        return t * t * (3 - 2 * t)
    }

    private func draw(_ scene: RouteScene, in context: inout GraphicsContext) {
        // The curtain, far walls first. It holds its color for a while before fading, so it reads as solid.
        if scene.amount > 0.01 {
            let top = emotion.routeCurtain
            let gradient = Gradient(stops: [
                .init(color: top, location: 0),
                .init(color: top.opacity(0.6), location: 0.45),
                .init(color: top.opacity(0), location: 1),
            ])
            for wall in scene.walls {
                context.fill(wall.path, with: .linearGradient(gradient, startPoint: wall.top, endPoint: wall.bottom))
            }
        }
        let style = StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round)
        // One solid color for the whole route (a faint "still ahead" part looked muddy over the curtain).
        context.stroke(scene.line, with: .color(emotion.color), style: style)
        guard let progress else { return }
        // A dot where the runner is, counting back from the end of the outline as the flat route did.
        let done = min(max(progress, 0), 1)
        if let runner = scene.line.trimmedPath(from: 0, to: 1 - done).currentPoint {
            let d = lineWidth * 3.5
            context.fill(Path(ellipseIn: CGRect(x: runner.x - d / 2, y: runner.y - d / 2, width: d, height: d)),
                         with: .color(emotion.color))
        }
    }
}

// MARK: - Geometry

/// One frame of the projected route.
private struct RouteScene {
    struct Wall { var path: Path; var top: CGPoint; var bottom: CGPoint; var depth: Double }

    var line = Path()
    var walls: [Wall] = []
    var amount: Double = 0

    /// The loop as evenly spaced points on the ground (x right, z away from you), centered and scaled so its
    /// widest side spans -1...1, with a height for each point.
    private struct Loop { var points: [(x: Double, z: Double)]; var heights: [Double] }
    private static var loops: [RouteShape: Loop] = [:]
    /// The area the route can ever cover (flat or full 3D), in projected units, so it fits without being cut
    /// and keeps one size while it turns.
    private static var extents: [String: CGRect] = [:]

    private static let distance = 4.0

    private static func loop(for route: RouteShape) -> Loop {
        if let cached = loops[route] { return cached }
        let count = 320
        let raw = route.outline
        let bounds = raw.boundingRect
        let half = max(bounds.width, bounds.height) / 2
        var points: [(x: Double, z: Double)] = []
        for i in 0..<count {
            let t = max(CGFloat(i) / CGFloat(count), 0.0001)
            let p = raw.trimmedPath(from: 0, to: t).currentPoint ?? .zero
            // Route y points down the screen, i.e. toward you; z points away.
            points.append((Double((p.x - bounds.midX) / half), Double((bounds.midY - p.y) / half)))
        }
        // A smooth, repeatable hill profile around the loop (whole-number waves, so it closes up).
        let seed = Double(RouteShape.allCases.firstIndex(of: route) ?? 0)
        let heights = (0..<count).map { i -> Double in
            let t = 2 * Double.pi * Double(i) / Double(count)
            let wave = 0.55 * sin(2 * t + seed * 1.7) + 0.3 * sin(3 * t + seed * 2.9) + 0.15 * sin(7 * t + seed)
            return 0.14 + 0.1 * (wave + 1)        // 0.14...0.34 of the loop's half-width
        }
        let loop = Loop(points: points, heights: heights)
        loops[route] = loop
        return loop
    }

    /// Projects a ground point at height `h` to unit screen space (y down), plus its depth (larger = farther).
    private static func project(_ x: Double, _ z: Double, _ h: Double, pitch: Double, yaw: Double) -> (CGPoint, Double) {
        let x1 = x * cos(yaw) - z * sin(yaw)
        let z1 = x * sin(yaw) + z * cos(yaw)
        let up = h * cos(pitch) + z1 * sin(pitch)
        let depth = z1 * cos(pitch) - h * sin(pitch)
        let f = distance / (distance + depth)
        return (CGPoint(x: x1 * f, y: -up * f), depth)
    }

    private static func pose(_ amount: Double, pitch3D: Double, yaw3D: Double) -> (pitch: Double, yaw: Double) {
        (Double.pi / 2 + (pitch3D - Double.pi / 2) * amount, yaw3D * amount)
    }

    private static func extent(for route: RouteShape, pitch3D: Double, yaw3D: Double, onlyFull3D: Bool) -> CGRect {
        let key = "\(route)-\(pitch3D)-\(yaw3D)-\(onlyFull3D)"
        if let cached = extents[key] { return cached }
        let loop = loop(for: route)
        var rect = CGRect.null
        for step in (onlyFull3D ? 8...8 : 0...8) {
            let p = pose(Double(step) / 8, pitch3D: pitch3D, yaw3D: yaw3D)
            for (i, q) in loop.points.enumerated() {
                for h in [0, loop.heights[i]] {
                    let (pt, _) = project(q.x, q.z, h, pitch: p.pitch, yaw: p.yaw)
                    rect = rect.union(CGRect(origin: pt, size: .zero))
                }
            }
        }
        extents[key] = rect
        return rect
    }

    static func aspect(for route: RouteShape, pitch3D: Double, yaw3D: Double, onlyFull3D: Bool) -> CGFloat {
        let e = extent(for: route, pitch3D: pitch3D, yaw3D: yaw3D, onlyFull3D: onlyFull3D)
        return e.height > 0 ? e.width / e.height : 1
    }

    static func make(route: RouteShape, size: CGSize, amount: Double, pitch3D: Double, yaw3D: Double,
                     onlyFull3D: Bool) -> RouteScene {
        let loop = loop(for: route)
        let e = extent(for: route, pitch3D: pitch3D, yaw3D: yaw3D, onlyFull3D: onlyFull3D)
        let inset: CGFloat = 8   // room for the line's thickness and the runner dot
        let scale = min((size.width - inset * 2) / e.width, (size.height - inset * 2) / e.height)
        let offset = CGPoint(x: size.width / 2 - e.midX * scale, y: size.height / 2 - e.midY * scale)
        let p = pose(amount, pitch3D: pitch3D, yaw3D: yaw3D)

        func place(_ x: Double, _ z: Double, _ h: Double) -> (CGPoint, Double) {
            let (pt, d) = project(x, z, h, pitch: p.pitch, yaw: p.yaw)
            return (CGPoint(x: offset.x + pt.x * scale, y: offset.y + pt.y * scale), d)
        }

        var scene = RouteScene(amount: amount)
        var tops: [CGPoint] = [], bottoms: [CGPoint] = [], depths: [Double] = []
        for (i, q) in loop.points.enumerated() {
            // The curtain grows in with the tilt, so the flat map has none.
            let (top, d) = place(q.x, q.z, loop.heights[i] * amount)
            let (bottom, _) = place(q.x, q.z, 0)
            tops.append(top); bottoms.append(bottom); depths.append(d)
        }
        scene.line.addLines(tops)
        scene.line.closeSubpath()

        guard amount > 0.01 else { return scene }
        let n = tops.count
        scene.walls = (0..<n).map { i in
            let j = (i + 1) % n
            var wall = Path()
            wall.addLines([tops[i], tops[j], bottoms[j], bottoms[i]])
            wall.closeSubpath()
            return Wall(path: wall,
                        top: CGPoint(x: (tops[i].x + tops[j].x) / 2, y: (tops[i].y + tops[j].y) / 2),
                        bottom: CGPoint(x: (bottoms[i].x + bottoms[j].x) / 2, y: (bottoms[i].y + bottoms[j].y) / 2),
                        depth: (depths[i] + depths[j]) / 2)
        }
        .sorted { $0.depth > $1.depth }
        return scene
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 24) {
            ForEach(RouteShape.allCases, id: \.self) { route in
                Route3DView(emotion: .stressed, route: route)
                    .padding(24)
            }
        }
    }
    .background(Color.black)
}
