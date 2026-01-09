
import Foundation

struct OnboardingOption: Identifiable, Hashable {
    let id: String
    let title: String
    let imageName: String
}

struct OnboardingStep: Identifiable {
    let id: String
    let question: String
    let options: [OnboardingOption]
}
