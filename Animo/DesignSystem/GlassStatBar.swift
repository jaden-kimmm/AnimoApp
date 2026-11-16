import SwiftUI

/// One stat in a `GlassStatBar`: a value under either a text label or an icon.
struct StatItem: Identifiable {
    let id = UUID()
    let label: String
    let icon: String
    let value: String
}

/// Run stats floating over a photo in Liquid Glass (Figma 486:6616). Smoky glass with white text, so it stays
/// dark and see-through instead of turning white. Four layouts to compare:
/// - `.text`: one wide capsule, a text label above each value.
/// - `.icon`: the same, with an icon above each value.
/// - `.separate`: each stat in its own glass tile.
/// - `.featured`: one glass card with the last stat (pace) big, and the rest in a row beneath it.
struct GlassStatBar: View {
    enum Style {
        case text, icon, separate, featured
    }

    let items: [StatItem]
    var style: Style = .text

    private var tint: Glass { .regular.tint(AppColor.glassTintDark) }

    var body: some View {
        switch style {
        case .text, .icon:
            HStack {
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    stat(item, caption: style == .icon ? .icon : .text, valueStyle: .body)
                        .fixedSize()
                    if index < items.count - 1 { Spacer(minLength: 8) }
                }
            }
            .padding(.horizontal, 24)
            .frame(height: 52)
            .glassEffect(tint, in: .capsule)

        case .separate:
            GlassEffectContainer(spacing: 8) {
                HStack(spacing: 8) {
                    ForEach(items) { item in
                        stat(item, caption: .text, valueStyle: .body)
                            .minimumScaleFactor(0.8)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .glassEffect(tint, in: .rect(cornerRadius: 20))
                    }
                }
            }

        case .featured:
            if let hero = items.last {
                VStack(alignment: .leading, spacing: 12) {
                    stat(hero, caption: .text, valueStyle: .headline)

                    HStack {
                        ForEach(Array(items.dropLast().enumerated()), id: \.element.id) { index, item in
                            stat(item, caption: .text, valueStyle: .body)
                                .fixedSize()
                            if index < items.count - 2 { Spacer(minLength: 8) }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .glassEffect(tint, in: .rect(cornerRadius: 28))
            }
        }
    }

    private enum Caption { case text, icon }

    /// A muted caption (text or icon) with its value beneath.
    private func stat(_ item: StatItem, caption: Caption, valueStyle: TextStyle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            switch caption {
            case .text:
                Text(item.label)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textOnDarkMuted)
            case .icon:
                Image(systemName: item.icon)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColor.textOnDarkMuted)
                    .frame(height: 18)
            }

            Text(item.value)
                .textStyle(valueStyle)
                .foregroundStyle(AppColor.textOnDark)
                .lineLimit(1)
        }
    }
}

#Preview {
    let items = [
        StatItem(label: "BPM", icon: "heart", value: "133"),
        StatItem(label: "Time", icon: "clock", value: "35:11"),
        StatItem(label: "Calories", icon: "flame", value: "621"),
        StatItem(label: "Pace", icon: "speedometer", value: "5.31 / mi")
    ]
    return ZStack {
        Image("Echo_Park_Run").resizable().scaledToFill().ignoresSafeArea()
        VStack(spacing: 16) {
            GlassStatBar(items: items, style: .text)
            GlassStatBar(items: items, style: .icon)
            GlassStatBar(items: items, style: .separate)
            GlassStatBar(items: items, style: .featured)
        }
        .padding(24)
    }
}
