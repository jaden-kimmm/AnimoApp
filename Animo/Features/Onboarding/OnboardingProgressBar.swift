import SwiftUI

struct OnboardingProgressBar: View {
    let totalSteps: Int
    let currentIndex: Int

    private let height: CGFloat = 5
    private let spacing: CGFloat = 5

    var body: some View {
        // Each tick is its own glass capsule. Completed steps are tinted dark; upcoming ones are plain glass.
        // The container's blend distance is kept smaller than the gap so the ticks stay separate.
        GlassEffectContainer(spacing: 2) {
            HStack(spacing: spacing) {
                ForEach(0..<totalSteps, id: \.self) { index in
                    Color.clear
                        .frame(maxWidth: .infinity)
                        .frame(height: height)
                        .glassEffect(
                            index <= currentIndex ? .regular.tint(AppColor.black) : .regular,
                            in: .capsule
                        )
                }
            }
        }
    }
}
