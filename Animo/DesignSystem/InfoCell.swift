import SwiftUI

/// Grey SF Symbol + label on top, value below. Headline value by default; pass `.body` / `.label`
/// for longer text such as a coach note. Used in the SelectedRun and AfterRun detail grids.
struct InfoCell: View {
    let icon: String
    let label: String
    let value: String
    var valueStyle: TextStyle = .headline
    /// Color of the icon and label above the value.
    var labelColor: Color = AppColor.textSecondary
    /// Color of the value. Pass `textOnDark` when the cell sits over a photo.
    var valueColor: Color = AppColor.textPrimary
    /// Gap between the label row and the value.
    var labelGap: CGFloat = 4

    var body: some View {
        VStack(alignment: .leading, spacing: labelGap) {
            HStack(alignment: .bottom, spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .frame(width: 18, height: 18)
                Text(label)
                    .textStyle(.label)
            }
            .foregroundStyle(labelColor)

            Text(value)
                .textStyle(valueStyle)
                .lineSpacing(valueStyle.designLineSpacing)
                .foregroundStyle(valueColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// 48pt interactive glass circle with a symbol, for header back / share buttons.
struct GlassCircleLabel: View {
    let systemName: String
    /// Icon color: dark on light screens, light when the circle floats over a photo.
    var foreground: Color = AppColor.textPrimary
    /// Tints the glass. Nil leaves it the standard light glass; pass a dark tint over photos so it stays subtle.
    var tint: Color?

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 20, weight: .regular))
            .foregroundStyle(foreground)
            .frame(width: 48, height: 48)
            .glassEffect(tint.map { Glass.regular.tint($0).interactive() } ?? Glass.regular.interactive(), in: .circle)
            .contentShape(Circle())
    }
}
