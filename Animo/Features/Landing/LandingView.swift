
import SwiftUI

struct LandingView: View {
    let onStart: () -> Void
    
    let onLogin: () -> Void
    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 12) {
                Text("Every stride, understood.")
                    .textStyle(.display)
                    .foregroundStyle(AppColor.white)
                
                Text("Motivation that feels human. \nSupport that stays with you. ")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.lightWhiteText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            
            VStack(spacing: 14) {

                PrimaryButton(title: "Start", style: .white) {
                    onStart()
                }
                .padding(.horizontal)
                
                Button {
                    onStart()
                } label: {
                    Text("Login")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.white)
                        .underline(true, color: AppColor.white)
                        .frame(maxWidth: .infinity)
                }
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Image("onboarding-bg-1")
                .resizable()
                .scaledToFill()
                .offset(x: -40)
                .ignoresSafeArea()
                .overlay {
                    Color.black.opacity(0.2).ignoresSafeArea()
                }
        }
        .overlay {
            Image("logo")
                .resizable()
                .scaledToFit()
                .foregroundColor(AppColor.white)
                .frame(width: 87, height: 87)
        }
    }
}

#Preview {
    ZStack {
        AppColor.bg.ignoresSafeArea()
        LandingView(
                onStart: {},
                onLogin: {}
        )
    }
}
