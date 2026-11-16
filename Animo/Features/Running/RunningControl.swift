
import SwiftUI

struct RunningControl: View {
    let emotion: Emotion
    let onEnd: () -> Void

    @State private var elapsedSeconds: Int = 12 * 60 + 44
    @State private var distanceMiles: Double = 2.40
    @State private var caloriesAcc: Double = 231.0
    @State private var turnDistanceFeet: Int = 500
    @State private var runTimer: Timer?
    @State private var isPaused: Bool = false

    var body: some View {
        ZStack{
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()
            
            AppColor.scrimLightSoft
                .ignoresSafeArea()

            // Always in 3D while running, with a dot for you: centered on the screen, then lifted a little so
            // it sits in the open space rather than leaning on the turn directions.
            Route3DView(emotion: emotion, route: .route1, alwaysIn3D: true, progress: 0.57)
                .padding(.horizontal, AppSpacing.screenMargin)
                .offset(y: -70)
                .allowsHitTesting(false)
            
            VStack(spacing: 8) {
                statsBar
                    .padding(.horizontal, AppSpacing.screenMargin)

                VStack {
                    Spacer()
                    VStack(alignment: .leading, spacing: 8) {
                        Image(systemName: "arrow.turn.up.left")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(emotion.color)
                            .frame(width: 44, height: 44)
                            .background(AppColor.black)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("In \(turnDistanceFeet)ft, turn left")
                                .textStyle(.display)
                                .foregroundStyle(AppColor.textPrimary)

                            Text("Parkway Ave.")
                                .textStyle(.body)
                                .foregroundStyle(AppColor.textPrimary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    GlassEffectContainer(spacing: 6) {
                        HStack(spacing: 6) {
                            glassControl(systemName: "xmark", label: "End run") {
                                stopSimulatedRunTimer()
                                isPaused = false
                                onEnd()
                            }

                            glassControl(
                                systemName: isPaused ? "play.fill" : "pause.fill",
                                label: isPaused ? "Resume run" : "Pause run"
                            ) {
                                isPaused.toggle()

                                if isPaused {
                                    stopSimulatedRunTimer()
                                } else {
                                    startSimulatedRunTimer()
                                }
                            }
                            .transaction { txn in
                                txn.animation = nil
                            }

                            glassControl(systemName: "ellipsis", label: "More") { }
                        }
                    }
                    .frame(maxWidth: .infinity)
            
                }
                .padding(.horizontal, AppSpacing.screenMargin)
            }
            .onAppear {
                startSimulatedRunTimer()
            }
            .onDisappear {
                stopSimulatedRunTimer()
                isPaused = false
            }
        }
    }

    // Figma 456:4839: three equal glass pills (icon + value) that mirror the three control tiles below.
    private var statsBar: some View {
        GlassEffectContainer(spacing: 6) {
            HStack(spacing: 6) {
                statPill(
                    systemName: "figure.run",
                    value: distanceMiles.formatted(.number.precision(.fractionLength(1))),
                    unit: "mi"
                )
                statPill(systemName: "flame.fill", value: "\(Int(caloriesAcc))", unit: "kcal")
                statPill(systemName: "stopwatch", value: timeString(from: elapsedSeconds), unit: nil)
            }
        }
    }

    private func statPill(systemName: String, value: String, unit: String?) -> some View {
        HStack(spacing: 6) {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppColor.textPrimary)

            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .textStyle(.button)
                    // Fixed-width digits so the ticking time and distance don't shift sideways.
                    .monospacedDigit()
                    .foregroundStyle(AppColor.textPrimary)
                if let unit {
                    Text(unit)
                        .textStyle(.label)
                        .foregroundStyle(AppColor.textSecondary)
                }
            }
        }
        .lineLimit(1)
        .frame(maxWidth: .infinity)
        .frame(height: 40)
        .glassEffect(.regular, in: .capsule)
    }

    private func glassControl(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 24, weight: .regular))
                .foregroundStyle(AppColor.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(height: 142)
                .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 20))
        .accessibilityLabel(label)
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startSimulatedRunTimer() {
        runTimer?.invalidate()

        runTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            distanceMiles += 0.0021
            caloriesAcc += 0.17

            if elapsedSeconds % 20 == 0 {
                turnDistanceFeet = max(turnDistanceFeet - 50, 50)
            }
        }
    }

    private func stopSimulatedRunTimer() {
        runTimer?.invalidate()
        runTimer = nil
    }
}

#Preview {
    RunningControl(emotion: .stressed, onEnd: { })
}
