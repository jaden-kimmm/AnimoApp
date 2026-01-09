import SwiftUI

struct OnboardingFinishView: View {
    let onFinish: () -> Void

    var body: some View {
        VStack {
            Spacer()
            VStack(spacing: 60) {
                VStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(AppColor.black)
                        .frame(width: 30, height: 30)
                }
                VStack(spacing: 20) {
                    Text("You’re all set!")
                        .textStyle(.headline)
                        .foregroundStyle(AppColor.black)
                    
                    Text("Welcome to \nAnimo")
                        .textStyle(.display)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppColor.black)
                    
                    Text("Your running journey starts here.")
                        .textStyle(.body)
                        .foregroundStyle(AppColor.black)
                }
            }
            Spacer()
            PrimaryButton(title: "Enter", style: .black) {
                onFinish()
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
    }
}

#Preview {
    OnboardingFinishView {
        print("Finish tapped")
    }
}
