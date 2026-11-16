
import SwiftUI

struct LandingView: View {
    let onStart: () -> Void
    
    let onLogin: () -> Void


    var body: some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 4) {
                Text("Every stride, understood.")
                    .textStyle(.display)
                    .lineSpacing(TextStyle.display.designLineSpacing)
                    .foregroundStyle(AppColor.textOnDark)

                Text("Motivation that feels human.\nSupport that stays with you.")
                    .textStyle(.body)
                    .lineSpacing(TextStyle.body.designLineSpacing)
                    .foregroundStyle(AppColor.textOnDarkMuted)
            }
            .frame(maxWidth: 282, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, AppSpacing.screenMargin)
            .padding(.bottom, AppSpacing.screenMargin)
            
            VStack(spacing: 14) {
                Button {
                    onStart()
                } label: {
                    Text("Start")
                        .textStyle(.button)
                        .foregroundStyle(AppColor.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .contentShape(Capsule())
                }
                .buttonStyle(.plain)
                // White-tinted glass so the button stays light and frosted like the logo. Plain `.glass`
                // adapts to the dark photo behind it and turns into a murky dark capsule.
                .glassEffect(.regular.tint(AppColor.glassTintWhite).interactive(), in: .capsule)
                .padding(.horizontal, AppSpacing.screenMargin)

                Button {
                    onStart()
                } label: {
                    Text("Login")
                        .textStyle(.button)
                        .foregroundStyle(AppColor.textOnDark)
                        .underline(true, color: AppColor.textOnDark)
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
                // Kept at the framing it had when it moved with tilt.
                .scaleEffect(1.25)
                .ignoresSafeArea()
        }
        .overlay {
            // Glass logo, centered on the full screen (not the safe area, which would sit it ~14pt low).
            Color.clear
                .frame(width: 87, height: 87)
                .glassEffect(.regular.tint(AppColor.glassTintWhite), in: AnimoLogoShape())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
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
