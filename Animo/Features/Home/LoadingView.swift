
import SwiftUI

/// Figma 476:5390. White fading into the emotion color, with the Animo logo as a tinted glass spinner and
/// "Crafting your run..." blurring in underneath.
struct LoadingView: View {
    let emotion: Emotion

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var angle: Double = 0
    @State private var textVisible = false

    private let logoWidth: CGFloat = 70
    /// One slow-fast-slow turn. The logo has 4-fold symmetry, so a quarter turn looks like a fresh start.
    private let spinDuration: Double = 0.9
    private let spinStep: Double = 90

    private let words = "Crafting your run...".split(separator: " ").map(String.init)
    /// Delay between one word starting to reveal and the next.
    private let wordDelay: Double = 0.3

    var body: some View {
        ZStack {
            background

            // Logo sits at the exact center of the screen, text hangs below it.
            glassLogo
                .overlay(alignment: .bottom) {
                    revealedText
                        .offset(y: 46)
                }
        }
        .task {
            textVisible = true
            guard !reduceMotion else { return }
            // Each beat eases in, speeds up, then eases out; the next beat starts slow again.
            while !Task.isCancelled {
                withAnimation(.easeInOut(duration: spinDuration)) { angle += spinStep }
                try? await Task.sleep(for: .seconds(spinDuration))
            }
        }
    }

    /// "Crafting your run...", one word at a time: each word sharpens out of a blur, a beat after the last.
    private var revealedText: some View {
        HStack(spacing: 6) {
            ForEach(Array(words.enumerated()), id: \.offset) { index, word in
                Text(word)
                    .textStyle(.headline)
                    .foregroundStyle(emotion.color)
                    .fixedSize()
                    .blur(radius: textVisible ? 0 : 20)
                    .opacity(textVisible ? 1 : 0)
                    .animation(
                        .easeInOut(duration: 0.6).delay(Double(index) * wordDelay),
                        value: textVisible
                    )
            }
        }
    }

    private var glassLogo: some View {
        Color.clear
            .frame(width: logoWidth, height: logoWidth * 0.98)
            .glassEffect(
                .regular.tint(emotion.color),
                in: AnimoLogoShape().rotation(.degrees(angle))
            )
    }

    private var background: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                stops: [
                    .init(color: AppColor.white, location: 0.5),
                    .init(color: emotion.color, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )

            // Soft emotion glow hanging off the top edge (Figma 476:5391).
            Ellipse()
                .fill(emotion.color)
                .frame(width: 542, height: 310)
                .blur(radius: 60)
                .offset(y: -252)
        }
        .ignoresSafeArea()
    }
}

#Preview("Stressed") {
    LoadingView(emotion: .stressed)
}

#Preview("Happy") {
    LoadingView(emotion: .happy)
}
