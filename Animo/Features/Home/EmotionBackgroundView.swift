import SwiftUI

enum Emotion: String, CaseIterable {
    case angry, stressed, anxious, tired, happy
}

struct EmotionBackgroundView: View {
    let emotion: Emotion

    private let blurAmount: CGFloat = 40
    private let opacity: Double = 0.92

    @State private var animate = false
    @State private var seeds: [BlobSeed] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.white.opacity(0.001)

                ForEach(Array(seeds.enumerated()), id: \.offset) { idx, seed in
                    blob(
                        in: geo.size,
                        seed: seed,
                        color: emotion.color,
                        index: idx
                    )
                }
            }
            .compositingGroup()
            .blur(radius: blurAmount)
            .opacity(opacity)
            .onAppear {
                if seeds.isEmpty {
                    seeds = presetSeeds()
                }
                withAnimation(.easeInOut(duration: 6.0).repeatForever(autoreverses: true)) {
                    animate = true
                }
            }
        }
        .ignoresSafeArea()
    }

    private func blob(in size: CGSize, seed: BlobSeed, color: Color, index: Int) -> some View {
        let p1 = CGPoint(
            x: seed.start.x * size.width,
            y: seed.start.y * size.height
        )
        let _ = CGPoint(
            x: seed.end.x * size.width,
            y: seed.end.y * size.height
        )

        let base = min(size.width, size.height)
        let breath: CGFloat = animate ? 1.20 : 0.90
        let blobSize = base * seed.scale * breath

        return Circle()
            .fill(color)
            .frame(width: blobSize, height: blobSize)
            .scaleEffect(
                x: seed.xStretch,
                y: seed.yStretch * (animate ? 1.01 : 0.99)
            )
            .position(p1)
    }

    private func presetSeeds() -> [BlobSeed] {
        [
            BlobSeed(
                start: CGPoint(x: 0.48, y: 0.01),
                end:   CGPoint(x: 0.51, y: 0.02),
                scale: 0.38,
                xStretch: 2.90,
                yStretch: 2.35,
                duration: 2.5,
                delay: 0.06
            ),
            BlobSeed(
                start: CGPoint(x: 0.52, y: 0.99),
                end:   CGPoint(x: 0.49, y: 0.98),
                scale: 0.38,
                xStretch: 2.90,
                yStretch: 2.35,
                duration: 2.8,
                delay: 0.18
            )
        ]
    }
}

struct BlobSeed {
    let start: CGPoint
    let end: CGPoint
    let scale: CGFloat
    let xStretch: CGFloat
    let yStretch: CGFloat
    let duration: Double
    let delay: Double
}

#Preview {
    ZStack {
        EmotionBackgroundView(emotion: .angry)
        VStack(spacing: 12) {
            Text("How are we feeling today?")
            Text("Angry")
                .font(.system(size: 44, weight: .regular))
        }
    }
}
