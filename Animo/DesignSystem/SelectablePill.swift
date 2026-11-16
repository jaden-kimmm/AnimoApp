import SwiftUI

struct SelectablePill: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                // Selected: the photo fills the pill on top of the glass, same as before.
                if isSelected {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 50)
                        .overlay(AppColor.scrimDarkSoft)
                        .clipShape(Capsule())
                        .transition(.opacity)
                }

                Text(title)
                    .textStyle(.button)
                    .foregroundStyle(isSelected ? AppColor.textOnDark : AppColor.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        // Default Liquid Glass pill.
        .glassEffect(.regular.interactive(), in: .capsule)
        .animation(.easeInOut(duration: 0.35), value: isSelected)
    }
}
