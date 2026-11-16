 
import SwiftUI

struct SelectedRun: View {
    let emotion: Emotion
    let onBack: () -> Void
    let onStart: () -> Void

    @State private var page: Int = 0

    private let swipeThreshold: CGFloat = 40

    var body: some View {
        ZStack {
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()
            
            AppColor.scrimLight
                .ignoresSafeArea()

            // Figma 469:4589. Header sits right under the status bar (no top padding).
            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 12)

                Text("Echo Park Run")
                    .textStyle(.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .padding(.bottom, 12)

                routeImage
                    .padding(.bottom, 16)

                information

                Spacer(minLength: 16)

                PrimaryButton(title: "Start", style: .black) {
                    onStart()
                }
            }
            .padding(.horizontal, AppSpacing.screenMargin)
            .padding(.bottom, AppSpacing.screenMargin)
        }
    }

    // MARK: - Sections

    /// Glass back + share circles with the city centered between them.
    private var header: some View {
        ZStack {
            Text("Los Angeles, CA")
                .textStyle(.label)
                .foregroundStyle(AppColor.textPrimary)

            HStack {
                Button {
                    onBack()
                } label: {
                    GlassCircleLabel(systemName: "arrow.left")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()

                ShareLink(item: "Echo Park Run, Los Angeles, CA") {
                    GlassCircleLabel(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share run")
            }
        }
    }

    private var routeImage: some View {
        Image("Echo_Park_Run_Bg")
            .resizable()
            // Fill the full content width and take whatever height is left; scaledToFit shrank the
            // image narrower than the 16pt margins once the info grid got taller.
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .overlay(alignment: .topLeading) {
                Text(page == 0 ? "Route" : "Intensity")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textOnDark)
                    .blurFade(active: true, trigger: page)
                    .padding(.top, 32)
                    .padding(.leading, 32)
            }
            .overlay {
                ZStack {
                    if page == 0 {
                        Route3DView(emotion: emotion, route: .route1)
                            .padding(24)
                            .blurFade(active: true, trigger: page)
                    } else {
                        IntensityGraphView(emotion: emotion)
                            .padding(24)
                            .blurFade(active: true, trigger: page)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .bottom) {
                PageIndicator(total: 2, current: page, glass: true)
                    .padding(.bottom, 24)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 10)
                    .onEnded { value in
                        if value.translation.width <= -swipeThreshold {
                            withAnimation(.easeInOut(duration: 0.2)) { page = 1 }
                        } else if value.translation.width >= swipeThreshold {
                            withAnimation(.easeInOut(duration: 0.2)) { page = 0 }
                        }
                    }
            )
    }

    /// Run details as a 2-column grid (Figma 476:5159): icon + grey label over a large value, with the
    /// coach note spanning both columns.
    private var information: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                InfoCell(icon: "sun.max", label: "Weather", value: "68°F, Clear")
                InfoCell(icon: "road.lanes", label: "Surface", value: "Pavement")
            }
            GridRow {
                InfoCell(icon: "figure.run", label: "Distance", value: "3.2 mi")
                InfoCell(icon: "clock", label: "Duration", value: "28 min")
            }
            GridRow {
                InfoCell(
                    icon: "note.text",
                    label: "A Note",
                    value: "I've kept the pace light today because you're feeling fried. No hills, just a steady rhythm to help.",
                    valueStyle: .body
                )
                .gridCellColumns(2)
            }
        }
    }
}

private struct BlurFade<T: Equatable>: ViewModifier {
    let trigger: T
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .blur(radius: isVisible ? 0 : 20)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                isVisible = false
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isVisible = true
                    }
                }
            }
            .onChange(of: trigger) { _, _ in
                withAnimation(.easeInOut(duration: 0.12)) {
                    isVisible = false
                }
                withAnimation(.easeInOut(duration: 0.35).delay(0.08)) {
                    isVisible = true
                }
            }
    }
}


private extension View {
    @ViewBuilder
    func blurFade<T: Equatable>(active: Bool, trigger: T) -> some View {
        if active {
            self.modifier(BlurFade(trigger: trigger))
        } else {
            self
        }
    }
}


#Preview {
    SelectedRun(
        emotion: .stressed,
        onBack: { },
        onStart: { }
    )
}
