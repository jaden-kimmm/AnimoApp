import SwiftUI

/// Figma 479:6316. Logo at the top, the welcome message centered on the screen, CTA at the bottom.
struct OnboardingFinishView: View {
    let onFinish: () -> Void

    /// Phone tilt that leans the ring (stays level in the Simulator, where a drag stands in for it).
    @State private var tilt = TiltModel()

    var body: some View {
        ZStack {
            // A slowly turning ring of Plutchik's emotion colors, running off both sides.
            ColorRingView(tilt: tilt)
            .ignoresSafeArea()

            VStack {
                Spacer()

                // Same dark-glass primary CTA as the onboarding "Next" buttons.
                PrimaryButton(title: "Next", style: .black) {
                    onFinish()
                }
                .padding(.horizontal, AppSpacing.screenMargin)
                .padding(.bottom, AppSpacing.screenMargin)
            }

            VStack(spacing: 8) {
                Text("Welcome to Animo!")
                    .textStyle(.display)
                    .lineSpacing(TextStyle.display.designLineSpacing)
                    .foregroundStyle(AppColor.textPrimary)

                Text("Your running journey starts here.")
                    .textStyle(.body)
                    .lineSpacing(TextStyle.body.designLineSpacing)
                    .foregroundStyle(AppColor.textSecondary)
            }
            .multilineTextAlignment(.center)
            .frame(maxWidth: 279)
            // The logo sits just above the headline, in the middle of the screen (Figma 479:6316).
            .overlay(alignment: .top) {
                AnimoLogoShape()
                    .fill(AppColor.black)
                    .frame(width: 32, height: 31)
                    .offset(y: -39)
            }

        }
        .onAppear { tilt.start() }
        .onDisappear { tilt.stop() }
        #if targetEnvironment(simulator)
        // The Simulator has no gyroscope: dragging a finger stands in for tilting the phone.
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    tilt.setTarget(
                        roll: Double(value.translation.width / 200) * TiltModel.maxTilt,
                        pitch: Double(value.translation.height / 200) * TiltModel.maxTilt
                    )
                }
                .onEnded { _ in tilt.setTarget(roll: 0, pitch: 0) }
        )
        #endif
    }
}

#Preview {
    OnboardingFinishView {
        print("Finish tapped")
    }
}
