
import SwiftUI

struct SelectablePill: View {
    let title: String
    let imageName: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ZStack {
                Capsule()
                    .fill(AppColor.white)

                if isSelected {
                    Image(imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 50)
                        .clipShape(Capsule())

                    Capsule()
                        .fill(AppColor.black.opacity(0.15))
                }

                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(isSelected ? AppColor.white : AppColor.black)
            }
            .frame(height: 50)
        }
    }
}
