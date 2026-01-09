
import SwiftUI

struct OnboardingFlowView: View {
    let onFinished: () -> Void

    private let steps: [OnboardingStep] = [
        OnboardingStep(
            id: "fitness_level",
            question: "How would you describe your current fitness level?",
            options: [
                OnboardingOption(id: "beginner", title: "Beginner", imageName: "fitness_beginner"),
                OnboardingOption(id: "intermediate", title: "Intermediate", imageName: "fitness_intermediate"),
                OnboardingOption(id: "advanced", title: "Advanced", imageName: "fitness_advanced")
            ]
        ),
        OnboardingStep(
            id: "primary_focus",
            question: "What is your primary focus for this training phase?",
            options: [
                OnboardingOption(id: "consistency", title: "Consistency", imageName: "Focus_Consistency"),
                OnboardingOption(id: "conditioning", title: "Conditioning", imageName: "Focus_Conditioning"),
                OnboardingOption(id: "speed_power", title: "Speed & Power", imageName: "Focus_Speed_Power")
            ]
        ),
        OnboardingStep(
            id: "weekly_sessions",
            question: "How many sessions do you aim to complete weekly?",
            options: [
                OnboardingOption(id: "runs_1_2", title: "1-2 Runs", imageName: "Session_1"),
                OnboardingOption(id: "runs_3_4", title: "3-4 Runs", imageName: "Session_3"),
                OnboardingOption(id: "runs_5_plus", title: "5+ Runs", imageName: "Session_5")
            ]
        ),
        OnboardingStep(
            id: "coaching_style",
            question: "Which coaching style aligns with your goals?",
            options: [
                OnboardingOption(id: "empathetic", title: "Empathetic", imageName: "Coaching_Empathetic"),
                OnboardingOption(id: "balanced", title: "Balanced", imageName: "Coaching_Balanced"),
                OnboardingOption(id: "performance", title: "Performance", imageName: "Coaching_Performance")
            ]
        ),
        OnboardingStep(
            id: "run_location",
            question: "Where do you primarily intend to track your runs?",
            options: [
                OnboardingOption(id: "pavement", title: "Pavement", imageName: "Location_Pavement"),
                OnboardingOption(id: "trail", title: "Trail", imageName: "Location_Trail"),
                OnboardingOption(id: "track", title: "Track", imageName: "Location_Track")
            ]
        )
    ]

    @State private var stepIndex: Int = 0
    @State private var selectedOptionID: String? = nil
    @State private var answers: [String: String] = [:]

    var body: some View {
        if stepIndex >= steps.count {
            OnboardingFinishView {
                print("Onboarding finished. Answers:", answers)
                onFinished()
            }
        } else {
            OnboardingQuestionView(
                step: steps[stepIndex],
                totalSteps: steps.count,
                stepIndex: stepIndex,
                selectedOptionID: $selectedOptionID
            ) {
                guard let selected = selectedOptionID else { return }

                answers[steps[stepIndex].id] = selected
                stepIndex += 1
                selectedOptionID = nil
            }
        }
    }
}

#Preview {
    ZStack {
        AppColor.bg.ignoresSafeArea()
        OnboardingFlowView {
            print("Preview: onboarding finished")
        }
    }
}
