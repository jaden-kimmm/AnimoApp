import SwiftUI

enum PrimaryButtonStyle {
    case black
    case white
}

struct PrimaryButton: View {
    let title: String
    var style: PrimaryButtonStyle = .white
    var height: CGFloat = 50
    var action: () -> Void

    var body: some View {
        switch style {
        case .black:
            // Primary CTA: dark Liquid Glass. The tint stays below full opacity so the glass rim,
            // highlights and refraction still show through instead of reading as flat black.
            Button(action: action) {
                Text(title)
                    .textStyle(.button)
                    .foregroundStyle(AppColor.textOnDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .contentShape(Capsule())
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.tint(AppColor.black).interactive(), in: .capsule)
            // Dark glass base: on the light #F7F7F7 background the default light glass washes the tint out to grey.
            .environment(\.colorScheme, .dark)

        case .white:
            Button(action: action) {
                Text(title)
                    .textStyle(.button)
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(maxWidth: .infinity)
                    .frame(height: height)
                    .background(AppColor.white)
                    .clipShape(Capsule())
                    .shadow(
                        color: AppColor.shadow,
                        radius: 4,
                        x: 0,
                        y: 4
                    )
            }
        }
    }
}
