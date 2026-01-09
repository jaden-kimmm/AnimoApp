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
        Button(action: action) {
            Text(title)
                .textStyle(.body)
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: height)
                .background(backgroundColor)
                .clipShape(Capsule())
                .shadow(
                        color: Color.black.opacity(0.25),
                        radius: 4,
                        x: 0,
                        y: 4
                    )
        }
    }

    private var backgroundColor: Color {
        switch style {
        case .white:
            return AppColor.white
        case .black:
            return AppColor.black
        }
    }

    private var textColor: Color {
        switch style {
        case .white:
            return AppColor.black
        case .black:
            return AppColor.white
        }
    }
}
