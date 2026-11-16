import SwiftUI

/// The 24 colors of Plutchik's wheel of emotions: eight emotions in wheel order, each in three
/// intensities from strongest to mildest (e.g. ecstasy, joy, serenity).
enum PlutchikColors {
    static let all: [Color] = [
        // Joy
        "#FFDD00", "#FFE95C", "#FFF4A8",
        // Trust
        "#5CB85C", "#8BD17C", "#C5E8B0",
        // Fear
        "#1E7B3A", "#4C9A5C", "#8FC49C",
        // Surprise
        "#3D8BE0", "#6BA9EA", "#A5CBF2",
        // Sadness
        "#1C1CC8", "#5757DB", "#9C9CEA",
        // Disgust
        "#C040D8", "#D277E3", "#E3AEEE",
        // Anger
        "#D0201F", "#E0504A", "#EE918B",
        // Anticipation
        "#F08A24", "#F5AB5C", "#F9CC95"
    ].map { Color(hex: $0) }

    /// The eight main emotions only, in wheel order, as clean saturated accents (joy, trust, fear,
    /// surprise, sadness, disgust, anger, anticipation).
    static let main: [Color] = [
        "#FFD60A", // joy
        "#30D158", // trust
        "#00A86B", // fear
        "#0A84FF", // surprise
        "#4338FF", // sadness
        "#BF40F2", // disgust
        "#FF3B30", // anger
        "#FF9F0A"  // anticipation
    ].map { Color(hex: $0) }
}

/// A ring of Liquid Glass circles in Plutchik's colors that slowly rotates around the center of the screen.
/// The ring is wider than the screen, so its sides run off the edges. With Reduce Motion on it stays still.
///
/// Pass a `TiltModel` and the ring leans in 3D as the phone tilts, like a plate hanging behind the glass.
/// Every circle is drawn flat and round at its projected spot, so it always faces the viewer; the side
/// leaning away gets smaller and a little fainter. Each circle casts a soft shadow on the screen.
struct ColorRingView: View {
    var colors: [Color] = PlutchikColors.main
    var circleDiameter: CGFloat = 60
    /// Space between neighboring circles along the ring. The number of circles follows from it, so a
    /// smaller gap means more circles (colors repeat in order as needed).
    var gap: CGFloat = 16
    /// Ring radius as a fraction of the view's width; above 0.5 the sides are cut off.
    var radiusFraction: CGFloat = 0.6
    var secondsPerRevolution: Double = 80
    /// Phone tilt that leans the ring. Nil keeps the ring flat.
    var tilt: TiltModel?
    /// How much the ring leans per radian of phone tilt (1 = same angle).
    var tiltAmount: Double = 1.5
    /// Perspective strength, 0...1: higher makes the near side bigger and the far side smaller.
    var depth: Double = 0.6

    /// Flip either to its opposite if the ring leans the wrong way when the phone tilts forward/back (pitch)
    /// or left/right (roll).
    private let pitchSign: Double = -1
    private let rollSign: Double = 1
    /// The ring never leans further than this, whatever the tilt (radians, about 70 degrees).
    private let maxLean: Double = 1.2

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// One circle, placed and sized for the current frame.
    private struct Dot: Identifiable {
        var id: Int
        var center: CGPoint
        var diameter: CGFloat
        var opacity: Double
        var z: CGFloat
        var color: Color
    }

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation(paused: reduceMotion)) { timeline in
                let dots = layout(in: geo.size, at: timeline.date)
                // `spacing: 0` keeps neighboring glass circles separate instead of melting into one blob.
                GlassEffectContainer(spacing: 0) {
                    ZStack {
                        ForEach(dots) { dot in
                            ZStack {
                                // The shadow is its own blurred disc: `.shadow` on the glass view found nothing
                                // to cast (glass isn't part of the view's own pixels), so it barely showed.
                                Circle()
                                    .fill(AppColor.dotShadow)
                                    .frame(width: dot.diameter * 0.9, height: dot.diameter * 0.9)
                                    .blur(radius: dot.diameter * 0.22)
                                    .offset(y: dot.diameter * 0.3)

                                Color.clear
                                    .frame(width: dot.diameter, height: dot.diameter)
                                    .glassEffect(.regular.tint(dot.color), in: .circle)
                            }
                            .opacity(dot.opacity)
                            .position(dot.center)
                        }
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    /// Places every circle for this frame, farthest first so nearer ones overlap them.
    private func layout(in size: CGSize, at date: Date) -> [Dot] {
        let time: Double = date.timeIntervalSinceReferenceDate
        let spin: Double = reduceMotion ? 0 : time / secondsPerRevolution * 2 * Double.pi
        let centerX: CGFloat = size.width / 2
        let centerY: CGFloat = size.height / 2
        let radius: CGFloat = size.width * radiusFraction
        let circumference: CGFloat = 2 * CGFloat.pi * radius
        let total = max(3, Int((circumference / (circleDiameter + gap)).rounded()))
        let count = Double(total)

        // How far the ring leans about the horizontal (x) and vertical (y) axes.
        var leanX: Double = 0
        var leanY: Double = 0
        if let tilt, !reduceMotion {
            tilt.step()
            leanX = min(max(tilt.pitch * tiltAmount * pitchSign, -maxLean), maxLean)
            leanY = min(max(tilt.roll * tiltAmount * rollSign, -maxLean), maxLean)
        }
        // Camera distance: closer means stronger perspective. Always beyond the ring's radius.
        let distance: CGFloat = radius * CGFloat(4 - 2.5 * min(max(depth, 0), 1))

        var dots: [Dot] = []
        for index in 0..<total {
            // Starts at the top of the ring and goes clockwise.
            let angle: Double = spin + 2 * Double.pi * Double(index) / count - Double.pi / 2
            let flatX: CGFloat = radius * CGFloat(cos(angle))
            let flatY: CGFloat = radius * CGFloat(sin(angle))
            // Lean about the x axis, then about the y axis (the ring starts flat, so z is 0).
            let y1: CGFloat = flatY * CGFloat(cos(leanX))
            let z1: CGFloat = flatY * CGFloat(sin(leanX))
            let x2: CGFloat = flatX * CGFloat(cos(leanY)) + z1 * CGFloat(sin(leanY))
            let z2: CGFloat = -flatX * CGFloat(sin(leanY)) + z1 * CGFloat(cos(leanY))

            let scale: CGFloat = distance / (distance - z2)
            // Only the side leaning away fades; a flat ring stays fully opaque.
            let away: CGFloat = min(max(-z2 / radius, 0), 1)
            dots.append(Dot(
                id: index,
                center: CGPoint(x: centerX + x2 * scale, y: centerY + y1 * scale),
                diameter: circleDiameter * scale,
                opacity: Double(1 - 0.45 * away),
                z: z2,
                color: colors[index % colors.count]
            ))
        }
        return dots.sorted { $0.z < $1.z }
    }
}

#Preview {
    let tilt = TiltModel()
    tilt.setTarget(roll: 0.4, pitch: -0.3)
    return ZStack {
        AppColor.bg.ignoresSafeArea()
        ColorRingView(tilt: tilt)
    }
}
