import SwiftUI

/// The runs, opened from the account sheet. Each run's photo fills the whole sheet; its lower half melts
/// into a progressive blur and darkens, and the title and details sit on top of that in white. Swipe left
/// or right to move between runs.
struct RunDetailView: View {
    /// All the runs you can swipe through, in list order.
    var runs: [RunSummary] = RunSummary.samples
    /// The run that was tapped; the pager opens on it.
    let run: RunSummary

    @Environment(\.dismiss) private var dismiss
    @State private var currentID: String?

    init(runs: [RunSummary] = RunSummary.samples, run: RunSummary) {
        self.runs = runs
        self.run = run
        _currentID = State(initialValue: run.id)
    }

    /// Figma 500:7983 (screen 852pt tall): the dots' bottom edge is 56pt above the screen's bottom, and the note's
    /// last line ends 99pt above it, a clear 38pt above the dots.
    private let dotsBottomFromScreen: CGFloat = 56
    private let textBottomFromScreen: CGFloat = 99

    private var current: RunSummary { runs.first { $0.id == currentID } ?? run }

    var body: some View {
        GeometryReader { outer in
            // A paging scroll view (not a page-style TabView) so it can stop dead at the first and last run
            // instead of stretching past the end when you keep swiping.
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    ForEach(runs) { item in
                        RunDetailPage(run: item, bottomPadding: textBottomFromScreen)
                            .containerRelativeFrame([.horizontal, .vertical])
                            .id(item.id)
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.paging)
            .scrollPosition(id: $currentID)
            .scrollBounceDisabled()
            .scrollIndicators(.hidden)
            .ignoresSafeArea()
            // Which run you're on, and that there are more to either side.
            .overlay(alignment: .bottom) {
                PageIndicator(total: runs.count, current: runs.firstIndex { $0.id == current.id } ?? 0, glass: true)
                    // This overlay is measured from the safe area's bottom edge, so take that inset off to land
                    // the dots a fixed distance from the screen's real bottom edge.
                    .padding(.bottom, max(dotsBottomFromScreen - outer.safeAreaInsets.bottom, 0))
                    .accessibilityHidden(true)
            }
        }
        .background(AppColor.black)
        .overlay(alignment: .top) { topBar }
        .toolbar(.hidden, for: .navigationBar)
        // The back button is the only way out: no swipe down, no edge swipe back.
        .interactiveDismissDisabled(true)
        .blocksSwipeToLeave()
    }

    // MARK: - Top bar

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                GlassCircleLabel(systemName: "arrow.left", foreground: AppColor.textOnDark, tint: AppColor.glassTintDark)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back")

            Spacer()

            ShareLink(item: "\(current.title), \(current.location)") {
                GlassCircleLabel(systemName: "square.and.arrow.up", foreground: AppColor.textOnDark, tint: AppColor.glassTintDark)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Share run")
        }
        .padding(.horizontal, 16)
        .padding(.top, 18)
    }
}

/// One run's page: the full-bleed photo with its progressive blur, and the details on top.
private struct RunDetailPage: View {
    let run: RunSummary
    let bottomPadding: CGFloat

    /// The blur builds in layers, each a stronger blur that fades in a little lower down the photo, so it
    /// grows smoothly from sharp to soft with no visible edge. (Plain SwiftUI blurs, so it works the same
    /// in the Simulator and on a phone, at any height; Glur's shader didn't draw on tall views in the Simulator.)
    /// `from`/`to` are fractions of the photo's height where that layer eases from invisible to fully shown.
    private static let blurLayers: [(radius: CGFloat, from: CGFloat, to: CGFloat)] = [
        (3, 0.38, 0.52),
        (8, 0.46, 0.62),
        (16, 0.55, 0.74),
        (28, 0.64, 0.88),
    ]
    /// The one spacing step between every block of text.
    private static let step: CGFloat = 16
    /// Where the darkening under the text starts and where it reaches full strength.
    private static let scrimRange: (from: CGFloat, to: CGFloat) = (0.36, 0.85)

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .bottomLeading) {
                backdrop(size: geo.size)

                VStack(alignment: .leading, spacing: 0) {
                    // The route floats over the sharp top of the photo, below the back and share buttons.
                    // Flat map at rest; tips into 3D as the phone tilts.
                    Route3DView(emotion: run.emotion, route: run.route)
                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: 360)
                        .padding(.top, 96)
                        .accessibilityLabel("Route")
                        // When space is short the route shrinks; the text never does.
                        .layoutPriority(-1)

                    Spacer(minLength: 24)

                    // One 16pt step throughout (Figma 500:7912): title block to grid, row to row, column to
                    // column, grid to note. Each label sits directly on its value.
                    VStack(alignment: .leading, spacing: Self.step) {
                        header
                        information
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, AppSpacing.screenMargin)
                .padding(.bottom, bottomPadding)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        // Each page runs edge to edge too; otherwise the photo stops short of the bottom.
        .ignoresSafeArea()
    }

    // MARK: - Photo

    private func backdrop(size: CGSize) -> some View {
        ZStack {
            photo(size: size)

            ForEach(Self.blurLayers.indices, id: \.self) { i in
                let layer = Self.blurLayers[i]
                photo(size: size)
                    .blur(radius: layer.radius, opaque: true)
                    .mask(Self.easedRamp(AppColor.black, from: layer.from, to: layer.to))
            }

            // Darkens the blurred half so white text reads on any photo.
            Self.easedRamp(AppColor.scrimDarkStrong, from: Self.scrimRange.from, to: Self.scrimRange.to)
        }
        .frame(width: size.width, height: size.height)
        .clipped()
        .allowsHitTesting(false)
    }

    private func photo(size: CGSize) -> some View {
        Image(run.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
    }

    /// A vertical ramp from clear (above `start`) to `color` (from `end` down), easing in and out
    /// (smootherstep) so neither end of the ramp shows as a line.
    private static func easedRamp(_ color: Color, from start: CGFloat, to end: CGFloat) -> LinearGradient {
        let steps = 16
        var stops: [Gradient.Stop] = [.init(color: color.opacity(0), location: 0)]
        for step in 0...steps {
            let t = Double(step) / Double(steps)
            let eased = t * t * t * (t * (t * 6 - 15) + 10)
            stops.append(.init(color: color.opacity(eased), location: start + (end - start) * CGFloat(t)))
        }
        stops.append(.init(color: color, location: 1))
        return LinearGradient(stops: stops, startPoint: .top, endPoint: .bottom)
    }

    // MARK: - Text

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(run.location)
                .textStyle(.label)
                .foregroundStyle(AppColor.textOnDarkMuted)

            Text(run.title)
                .textStyle(.display)
                .foregroundStyle(AppColor.textOnDark)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
    }

    private var information: some View {
        Grid(alignment: .topLeading, horizontalSpacing: Self.step, verticalSpacing: Self.step) {
            GridRow {
                cell(icon: "sun.max", label: "Weather", value: run.weather)
                cell(icon: "road.lanes", label: "Surface", value: run.surface)
            }
            GridRow {
                cell(icon: "figure.run", label: "Distance", value: run.distance)
                cell(icon: "clock", label: "Duration", value: run.time)
            }
            GridRow {
                cell(icon: "note.text", label: "A Note", value: run.note, style: .body)
                    .gridCellColumns(2)
            }
        }
    }

    private func cell(icon: String, label: String, value: String, style: TextStyle = .headline) -> InfoCell {
        InfoCell(icon: icon, label: label, value: value, valueStyle: style,
                 labelColor: AppColor.textOnDarkMuted, valueColor: AppColor.textOnDark, labelGap: 0)
    }
}

#Preview {
    RunDetailView(run: RunSummary.samples[1])
}
