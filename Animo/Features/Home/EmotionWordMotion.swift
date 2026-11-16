import SwiftUI

// MARK: - The motion of the big Home word
//
// Every emotion moves its letters one by one, in a way that should feel like the word itself:
//   Happy    rhythmic and up         (pops in, a skipping bounce wave)
//   Angry    fast, then smashed      (races in from the left, smashes into a wall, clenched + flares)
//   Stressed breathing               (the whole word slowly swells and shrinks, in and out)
//   Anxious  twitchy                 (letters blink on in random order, then twitch, freeze, twitch)
//   Tired    slow, weightless        (written out by hand, then letters float like they're in space)
//
// Each one is a pure function of time since the word appeared, so the entrance flows into the idle
// loop with no state machine. All tuning numbers live in one enum per emotion.

/// How one letter is placed this frame, on top of where the text layout put it.
struct GlyphPose {
    var dx: CGFloat = 0
    var dy: CGFloat = 0            // positive is down
    var rotation: Double = 0       // degrees
    var sx: CGFloat = 1
    var sy: CGFloat = 1
    var opacity: Double = 1
    var blur: CGFloat = 0
    /// Scale and rotate around the baseline (feet on the ground) instead of the letter's middle.
    var anchorBaseline = false
    /// Speed streaks: faded copies trailing to the left, this far apart.
    var streaks = 0
    var streakGap: CGFloat = 0
}

/// What a pose function knows about the letter it is placing.
struct GlyphInfo {
    let index: Int
    let count: Int
    /// The letter's center minus the word's center, in points (negative = left half).
    let cx: CGFloat
    /// The letter's own width.
    let width: CGFloat
    /// Half the word's width.
    let halfWidth: CGFloat
    /// 0 for the first letter, 1 for the last.
    var u: Double { count > 1 ? Double(index) / Double(count - 1) : 0 }
    var minX: CGFloat { cx - width / 2 }
}

struct EmotionWordRenderer: TextRenderer {
    let emotion: Emotion
    /// Seconds since this word appeared.
    let time: Double

    // Room so jumping, smashing and blurred letters are never clipped (Angry races in from off screen).
    var displayPadding: EdgeInsets { EdgeInsets(top: 40, leading: 600, bottom: 140, trailing: 80) }

    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for line in layout {
            let lineRect = line.typographicBounds.rect
            let slices = line.flatMap { $0 }
            for (index, slice) in slices.enumerated() {
                let bounds = slice.typographicBounds
                let info = GlyphInfo(
                    index: index,
                    count: slices.count,
                    cx: bounds.rect.midX - lineRect.midX,
                    width: bounds.rect.width,
                    halfWidth: lineRect.width / 2
                )
                let pose = emotion.pose(for: info, at: time)
                guard pose.opacity > 0.001 else { continue }

                // Faded copies behind a fast-moving letter.
                for s in stride(from: pose.streaks, through: 1, by: -1) {
                    var ghost = pose
                    ghost.dx -= pose.streakGap * CGFloat(s)
                    ghost.opacity *= 0.4 * (1 - Double(s) / Double(pose.streaks + 1))
                    draw(slice, bounds: bounds, pose: ghost, lineMinX: lineRect.minX, in: ctx)
                }
                draw(slice, bounds: bounds, pose: pose, lineMinX: lineRect.minX, in: ctx)
            }
        }
    }

    private func draw(_ slice: Text.Layout.RunSlice, bounds: Text.Layout.TypographicBounds,
                      pose: GlyphPose, lineMinX: CGFloat, in ctx: GraphicsContext) {
        var c = ctx
        let anchor = CGPoint(x: bounds.rect.midX, y: pose.anchorBaseline ? bounds.origin.y : bounds.rect.midY)
        c.translateBy(x: anchor.x + pose.dx, y: anchor.y + pose.dy)
        c.rotate(by: .degrees(pose.rotation))
        c.scaleBy(x: pose.sx, y: pose.sy)
        c.translateBy(x: -anchor.x, y: -anchor.y)
        c.opacity = max(0, min(1, pose.opacity))
        if pose.blur > 0.05 { c.addFilter(.blur(radius: pose.blur)) }

        c.draw(slice)
    }
}

extension Emotion {
    func pose(for g: GlyphInfo, at t: Double) -> GlyphPose {
        switch self {
        case .happy: return HappyMotion.pose(g, t)
        case .angry: return AngryMotion.pose(g, t)
        case .stressed: return StressedMotion.pose(g, t)
        case .anxious: return AnxiousMotion.pose(g, t)
        case .tired: return TiredMotion.pose(g, t)
        }
    }
}

// MARK: - Happy: a skip in your step

private enum HappyMotion {
    static let stagger = 0.07        // left-to-right pop-in
    static let popDuration = 0.55
    static let rise: CGFloat = 40    // how far below the letters start
    static let period = 1.4          // one bounce wave across the word
    static let waveSpread = 0.6      // how much of a period the wave lags from first to last letter
    static let hop: CGFloat = 6
    static let wobble = 3.0          // degrees

    static func pose(_ g: GlyphInfo, _ t: Double) -> GlyphPose {
        var p = GlyphPose(anchorBaseline: true)

        // Entrance: pop up from below with a springy overshoot.
        let delay = Double(g.index) * stagger
        let e = Motion.clamp01((t - delay) / popDuration)
        let back = Motion.easeOutBack(e, overshoot: 2.2)
        p.dy = (1 - back) * rise
        p.opacity = Motion.clamp01(e * 3)
        let popScale = 0.6 + 0.4 * back
        p.sx = popScale
        p.sy = popScale

        // Idle: a hop that travels across the word, with stretch in the air and squash on landing.
        let w = Motion.clamp01((t - delay - popDuration) / 0.35)
        guard w > 0 else { return p }
        let phase = Motion.frac(t / period - g.u * waveSpread)
        var air = 0.0, squash = 0.0
        if phase < 0.5 {
            air = sin(.pi * phase / 0.5)
        } else if phase < 0.62 {
            squash = sin(.pi * (phase - 0.5) / 0.12)
        }
        p.dy -= hop * air * w
        p.sy *= 1 + (0.05 * air - 0.09 * squash) * w
        p.sx *= 1 + (-0.03 * air + 0.07 * squash) * w
        p.rotation = wobble * sin(2 * .pi * phase) * (air > 0 ? 1 : 0.3) * w
        return p
    }
}

// MARK: - Angry: races in and smashes into a wall

private enum AngryMotion {
    static let stretch: CGFloat = 1.18   // wider than the font goes: the word drawn as stretched outlines
    static let travel = 0.2              // the whole race, off screen to the middle
    static let distance: CGFloat = 520
    static let speedStretch: CGFloat = 1.25
    static let squish: CGFloat = 0.34    // how much the word crumples against the wall on impact
    static let vibration: CGFloat = 0.5
    static let flarePeriod = 3.0         // a smaller smash roughly every 2.5-3.5s
    static let flareJitter = 0.9
    static let flareSquish: CGFloat = 0.1

    static func pose(_ g: GlyphInfo, _ t: Double) -> GlyphPose {
        var p = GlyphPose(anchorBaseline: true)
        let i = Double(g.index)
        let restX = g.cx * stretch                 // where the letter sits in the stretched word
        let wall = g.halfWidth * stretch           // the invisible wall at the word's right edge

        // Entrance: accelerate in from the left, stretched by speed, with streaks behind it.
        if t < travel {
            let e = pow(t / travel, 1.6)
            p.dx = restX - g.cx - (1 - CGFloat(e)) * distance
            p.sx = stretch * speedStretch
            p.sy = 0.92
            p.streaks = 4
            p.streakGap = 26
            return p
        }

        // Impact: the front stops dead at the wall, the rest piles in behind it (an accordion anchored
        // at the right edge), bulges up, then springs back out.
        let tt = t - travel
        var k = 1 - squish * CGFloat(exp(-tt * 9) * cos(tt * 15))
        var shake = 3 * CGFloat(exp(-tt * 12) * sin(tt * 80 + i))
        var tilt = 0.0

        // Idle: clenched, with irregular smaller smashes against the same wall.
        let w = CGFloat(Motion.clamp01((tt - 0.5) / 0.3))
        let kf = floor(t / flarePeriod)
        let start = kf * flarePeriod + Motion.hash(Int(kf)) * flareJitter
        let f = t - start
        if kf >= 1, f >= 0, f < 0.45 {
            let env = CGFloat(f < 0.03 ? f / 0.03 : exp(-(f - 0.03) * 11))
            k *= 1 - flareSquish * env
            shake += env * 3 * CGFloat(sin(f * 100 + i * 2))
            tilt = Double(env) * 2.5 * sin(f * 80 + i * 1.9)
        }

        let x = wall + (restX - wall) * k
        p.dx = x - g.cx + vibration * CGFloat(sin(t * 95 + i * 1.7)) * w
        p.dy = shake + vibration * 0.8 * CGFloat(sin(t * 83 + i * 2.3)) * w
        p.sx = stretch * k
        p.sy = 1 + (1 - k) * 0.6
        p.rotation = tilt
        // A short trail as it hits.
        if tt < 0.06 {
            p.streaks = 2
            p.streakGap = 14 * CGFloat(1 - tt / 0.06)
        }
        return p
    }
}

// MARK: - Stressed: one slow breath in, one slow breath out

private enum StressedMotion {
    // The whole word swells and shrinks from its center like a chest breathing. A breath in takes a bit
    // less time than the breath out, and each eases to a stop, so there's a natural pause at the top and
    // bottom of every breath. It starts exhaled and never resets.
    static let period = 7.0             // one full breath, in and out
    static let inhalePortion = 0.45     // share of the breath spent breathing in
    static let exhaled: CGFloat = 0.94  // scale at the bottom of a breath
    static let inhaled: CGFloat = 1.08  // scale at the top
    static let fadeIn = 0.8

    static func pose(_ g: GlyphInfo, _ t: Double) -> GlyphPose {
        var p = GlyphPose()
        p.opacity = Motion.easeOutCubic(t / fadeIn)

        let ph = Motion.frac(t / period)
        let breath = ph < inhalePortion
            ? smooth(ph / inhalePortion)
            : 1 - smooth((ph - inhalePortion) / (1 - inhalePortion))
        let scale = exhaled + (inhaled - exhaled) * CGFloat(breath)

        // Scale the whole word from its center: each letter grows, and moves out from the middle to match.
        p.sx = scale
        p.sy = scale
        p.dx = g.cx * (scale - 1)
        return p
    }

    /// Eases in and out with zero speed at both ends.
    private static func smooth(_ x: Double) -> Double {
        let c = Motion.clamp01(x)
        return c * c * (3 - 2 * c)
    }
}

// MARK: - Anxious: twitch, freeze, twitch

private enum AnxiousMotion {
    static let stepDelay = 0.14        // letters blink on one at a time, in a random order
    static let slot = 0.42             // each letter gets a chance to twitch this often
    static let twitchChance = 0.45     // ... and takes it this often
    static let groupSlot = 1.1         // sometimes the whole word twitches at once
    static let groupChance = 0.5
    static let jump: CGFloat = 4.5
    static let jolt = 12.0             // degrees

    static func pose(_ g: GlyphInfo, _ t: Double) -> GlyphPose {
        var p = GlyphPose()
        let i = g.index

        // Entrance: a random order (a stable shuffle), each letter snapping on with a jolt.
        let key = Motion.hash(i + 17)
        let rank = (0..<g.count).filter { Motion.hash($0 + 17) < key }.count
        let a = t - Double(rank) * stepDelay
        guard a > 0 else { p.opacity = 0; return p }
        p.opacity = Motion.clamp01(a / 0.03)
        let snap = CGFloat(max(0, 1 - a / 0.1))
        p.sx = 1 + 0.18 * snap
        p.sy = 1 + 0.18 * snap
        p.rotation = (key - 0.5) * 20 * Double(snap)

        // Idle: completely still, then a sharp twitch to a random spot and straight back.
        guard a > 0.3 else { return p }
        var best = 0.0, seed = 0
        let x = t / slot + Motion.hash(i + 5)
        let k = Int(floor(x))
        if Motion.hash(k * 31 + i * 7) > 1 - twitchChance {
            let env = twitch(at: (x - floor(x)) * slot - Motion.hash(k * 13 + i) * 0.2)
            if env > best { best = env; seed = k * 97 + i }
        }
        let gx = t / groupSlot
        let gk = Int(floor(gx))
        if Motion.hash(gk * 53 + 1000) > 1 - groupChance {
            let env = twitch(at: (gx - floor(gx)) * groupSlot - 0.3 - Double(i) * 0.008)
            if env > best { best = env; seed = gk * 89 + i + 5000 }
        }
        guard best > 0 else { return p }
        let e = CGFloat(best)
        p.dx += (CGFloat(Motion.hash(seed)) - 0.5) * 2 * jump * e
        p.dy += (CGFloat(Motion.hash(seed + 1)) - 0.5) * 2 * jump * e
        p.rotation += (Motion.hash(seed + 2) - 0.5) * 2 * jolt * best
        let s = 1 + (CGFloat(Motion.hash(seed + 3)) - 0.5) * 0.14 * e
        p.sx *= s; p.sy *= s
        p.opacity *= 1 - 0.25 * best
        return p
    }

    /// Snap out in 25ms, hold, snap back by 140ms. Zero the rest of the time.
    private static func twitch(at f: Double) -> Double {
        if f < 0 || f > 0.14 { return 0 }
        if f < 0.025 { return f / 0.025 }
        if f < 0.07 { return 1 }
        return 1 - Motion.easeOutCubic((f - 0.07) / 0.07)
    }
}

// MARK: - Tired: written by hand, then floating

private enum TiredMotion {
    static let floatStart = PenStrokes.Tired.duration + 0.3
    static let drift: CGFloat = 2.5    // points; small, slow, each letter on its own path
    static let bob: CGFloat = 3
    static let sway = 2.5              // degrees
    static let pace = 0.2              // lower = slower drift

    static func pose(_ g: GlyphInfo, _ t: Double) -> GlyphPose {
        var p = GlyphPose(anchorBaseline: true)
        let i = Double(g.index)

        // Entrance: the pen writes the word (drawn by `PenReveal`, not here); the letters hold still meanwhile.

        // Idle: letters float slowly, as if weightless.
        let w = CGFloat(Motion.clamp01((t - floatStart) / 1.5))
        guard w > 0 else { return p }
        p.dx = drift * CGFloat(Motion.noise(t * pace * 1.1, seed: i * 5)) * w
        p.dy = bob * CGFloat(Motion.noise(t * pace * 0.95, seed: i * 5 + 1)) * w
        p.rotation = sway * Motion.noise(t * pace * 0.85, seed: i * 5 + 2) * Double(w)
        return p
    }
}

// MARK: - Pen strokes (handwriting)

/// How the Tired word gets written out. The strokes below were traced over the font in the order the user
/// drew them on the tracing pad; from them `TiredPenMap` (in the asset catalog) was baked offline: every spot
/// on the word stores when the pen reaches its nearest point. `PenReveal` shows ink only where that time has
/// passed, so a stroke grows from the pen tip and never shows bits of a neighbouring stroke early.
/// If you change the strokes or the timing constants, re-bake the map (the timing must match it).
enum PenStrokes {
    enum Tired {
        static let start = 0.2             // first touch-down
        static let penLift = 0.06          // pause between strokes
        static let speed: CGFloat = 130    // points per second while the pen is moving
        static let strokeBase = 0.06       // every stroke takes at least this long

        /// x from the word's start, y up from the baseline, at 64pt with -1.92 tracking. In order: T bar,
        /// T stem, i dot, i stem, r (down, back up, over), e, and d in one stroke (stem from the top, back up,
        /// around the bowl, out along the bottom).
        private typealias RawStroke = [(CGFloat, CGFloat)]
        private static let raw: [RawStroke] = [
            [(-3.5, 30.6), (4, 31.8), (12.5, 33.1), (22.5, 34.4), (30, 35.2), (37, 35.3)],
            [(12.3, 34.6), (14.5, 27), (16.9, 18.75), (18.8, 13), (20.6, 7.5), (22.3, 3), (23.1, -1.4)],
            [(26.8, 30), (28.8, 30.3), (30.8, 29.4)],
            [(28.6, 17), (30, 12), (31.5, 8.5), (32.6, 6)],
            [(40, 20.5), (40.2, 13), (40.6, 6), (40.4, 12), (41, 16.5), (43, 19), (46.25, 20.2), (50.4, 19.8)],
            [(60, 15.6), (63, 16.8), (65, 18.75), (65, 21.6), (63.5, 23.1), (60.5, 23.6), (57.5, 22.3),
             (55.6, 18.5), (55.3, 13), (56.25, 8.75), (58.5, 5.5), (61.25, 3.75), (64.5, 3.6), (67.5, 4.8),
             (71.4, 7)],
            [(83.1, 44.6), (84.6, 36), (86.4, 27), (88.3, 19), (90, 12), (91.4, 7.5), (92, 5.6), (91.2, 8.5),
             (89.6, 11.5), (87.8, 13.5), (86.8, 17), (85.8, 20.2), (83, 21), (80, 20.6), (77.8, 18),
             (76.6, 14), (76.9, 10), (77.8, 7), (80, 5), (82.5, 4.9), (85, 6.2), (88, 7), (91.4, 7.2)],
        ]

        /// How much faster than the baked timing the word is written out. The map stores each spot's time as a
        /// share of the whole write, so speeding up playback keeps every stroke in step.
        static let playbackSpeed = 1.8
        /// How long writing the word takes on screen (about 1.7s).
        static var duration: Double { writeEnd / playbackSpeed }

        /// When the last stroke finishes at the baked timing (about 3.07s).
        static let writeEnd: Double = raw.reduce(start - penLift) { t, stroke in
            let length = zip(stroke, stroke.dropFirst()).reduce(CGFloat(0)) { $0 + hypot($1.1.0 - $1.0.0, $1.1.1 - $1.0.1) }
            return t + penLift + strokeBase + Double(length / speed)
        }

        /// The map's area in design units (minX, maxY, width, height) and its rows (word area, total with ramp).
        static let mapField: (minX: Float, maxY: Float, width: Float, height: Float) = (-8, 50, 108, 58)
        static let mapRows: (word: Float, total: Float) = (464, 472)
        static let ascender: CGFloat = 48
    }
}

/// Writes the Tired word out by hand while `progress` runs 0...1.
struct PenReveal: ViewModifier {
    let progress: Double
    /// Room around the text so letters that hang past its box (the T's bar) aren't cut off by the effect.
    private let pad: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .padding(pad)
            .colorEffect(ShaderLibrary.penReveal(
                .image(Image("TiredPenMap")),
                .float2(Float(pad), Float(pad + PenStrokes.Tired.ascender)),
                .float4(PenStrokes.Tired.mapField.minX, PenStrokes.Tired.mapField.maxY,
                        PenStrokes.Tired.mapField.width, PenStrokes.Tired.mapField.height),
                .float2(PenStrokes.Tired.mapRows.word, PenStrokes.Tired.mapRows.total),
                .float(Float(progress))
            ))
            .padding(-pad)
    }
}

// MARK: - Motion math

enum Motion {
    static func clamp01(_ x: Double) -> Double { min(1, max(0, x)) }
    static func frac(_ x: Double) -> Double { x - floor(x) }

    static func easeInCubic(_ x: Double) -> Double { let c = clamp01(x); return c * c * c }
    static func easeOutCubic(_ x: Double) -> Double { let c = 1 - clamp01(x); return 1 - c * c * c }
    static func easeOutBack(_ x: Double, overshoot s: Double = 1.70158) -> Double {
        let c = clamp01(x) - 1
        return 1 + c * c * ((s + 1) * c + s)
    }

    /// 0 outside `center ± width`, rising to 1 at `center`.
    static func bump(_ x: Double, center: Double, width: Double) -> Double {
        let d = abs(x - center) / width
        guard d < 1 else { return 0 }
        return 0.5 * (1 + cos(.pi * d))
    }

    /// A stable pseudo-random number in 0..<1 for an integer.
    static func hash(_ n: Int) -> Double {
        var x = UInt64(bitPattern: Int64(n)) &+ 0x9E3779B97F4A7C15
        x = (x ^ (x >> 30)) &* 0xBF58476D1CE4E5B9
        x = (x ^ (x >> 27)) &* 0x94D049BB133111EB
        x ^= x >> 31
        return Double(x % 1_000_000) / 1_000_000
    }

    /// Smooth 1D value noise in -1...1. `seed` gives each letter its own unrelated wander.
    static func noise(_ x: Double, seed: Double) -> Double {
        let xs = x + seed * 31.7
        let i = floor(xs)
        let f = xs - i
        let s = f * f * (3 - 2 * f)
        let a = hash(Int(i)) * 2 - 1
        let b = hash(Int(i) + 1) * 2 - 1
        return a + (b - a) * s
    }
}

// MARK: - The animated word

/// One emotion's word, moving. Re-create it (`.id(emotion)`) to replay the entrance.
struct AnimatedEmotionWord: View {
    let emotion: Emotion

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var start = Date.now

    var body: some View {
        if reduceMotion {
            word
        } else {
            TimelineView(.animation) { context in
                let time = max(0, context.date.timeIntervalSince(start))
                let animated = word.textRenderer(EmotionWordRenderer(emotion: emotion, time: time))
                if emotion == .tired, time < PenStrokes.Tired.duration {
                    animated.modifier(PenReveal(progress: time / PenStrokes.Tired.duration))
                } else {
                    animated
                }
            }
        }
    }

    private var word: some View {
        Text(emotion.wordText)
            .font(emotion.wordFont)
            .tracking(emotion.wordTracking)
            .foregroundStyle(emotion.wordColor)
            .fixedSize()
    }
}

#Preview("Word motion") {
    VStack(spacing: 40) {
        ForEach(Emotion.allCases, id: \.self) { emotion in
            AnimatedEmotionWord(emotion: emotion)
        }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color(hex: "#F7F7F7"))
}
