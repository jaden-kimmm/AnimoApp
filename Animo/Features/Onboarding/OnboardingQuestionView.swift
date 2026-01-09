
import SwiftUI

struct OnboardingQuestionView: View {
    let step: OnboardingStep
    let totalSteps: Int
    let stepIndex: Int
    @Binding var selectedOptionID: String?
    let onNext: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 50) {
            OnboardingProgressBar(totalSteps: totalSteps, currentIndex: stepIndex)

            Spacer()

            Text(step.question)
                .textStyle(.headline)
                .foregroundStyle(AppColor.black)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 10) {
                ForEach(step.options) { option in
                    SelectablePill(
                        title: option.title,
                        imageName: option.imageName,
                        isSelected: selectedOptionID == option.id
                    ) {
                        selectedOptionID = option.id
                    }
                }
            }

            if selectedOptionID != nil {
                PrimaryButton(title: "Next", style: .black) {
                    onNext()
                }
            } else {
                Color.clear.frame(height: 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 24)
        .padding(.bottom, 24)
    }
}
