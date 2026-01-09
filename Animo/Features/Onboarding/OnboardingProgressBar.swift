import SwiftUI

struct OnboardingProgressBar: View {
    let totalSteps: Int
    let currentIndex: Int

    private let height: CGFloat = 5
    private let spacing: CGFloat = 5

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<totalSteps, id: \.self) { index in
                Capsule()
                    .fill(index <= currentIndex ? AppColor.black : AppColor.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
            }
        }
    }
}
