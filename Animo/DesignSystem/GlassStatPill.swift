import SwiftUI

/// A small Liquid Glass capsule with an SF Symbol and a value, for run stats floating over a photo
/// (Figma 486:6532). Put several in a `GlassEffectContainer` so the glass renders together.
struct GlassStatPill: View {
    let icon: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text(value)
                .textStyle(.label)
        }
        .foregroundStyle(AppColor.textOnDark)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .glassEffect(.regular, in: .capsule)
    }
}

#Preview {
    ZStack {
        Image("Echo_Park_Run").resizable().scaledToFill().ignoresSafeArea()
        GlassEffectContainer(spacing: 8) {
            HStack(spacing: 8) {
                GlassStatPill(icon: "heart", value: "133")
                GlassStatPill(icon: "clock", value: "35:11")
                GlassStatPill(icon: "flame", value: "621")
                GlassStatPill(icon: "speedometer", value: "5.31 / mi")
            }
        }
    }
}
