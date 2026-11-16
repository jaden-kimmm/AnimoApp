
import SwiftUI

struct PageIndicator: View {
    let total: Int
    let current: Int
    /// Liquid Glass ticks (Home). The flat white ticks are still used over the run preview image.
    var glass: Bool = false

    var body: some View {
        if glass {
            // Each tick is its own glass shape; the active one is a tinted capsule so it stands out.
            // The container's blend distance is smaller than the 4pt gap so ticks don't merge.
            // Each tick is one capsule that springs between a 6pt dot and the 40pt pill (same view, not a
            // swap), so the active pill stretches across like liquid as you swipe.
            GlassEffectContainer(spacing: 2) {
                HStack(spacing: 4) {
                    ForEach(0..<total, id: \.self) { index in
                        let isActive = index == current
                        Color.clear
                            .frame(width: isActive ? 40 : 6, height: 6)
                            .glassEffect(
                                isActive ? .regular.tint(AppColor.glassTintLight) : .regular,
                                in: .capsule
                            )
                    }
                }
            }
            .animation(Self.tickSpring, value: current)
        } else {
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { index in
                    let isActive = index == current
                    Capsule()
                        .fill(AppColor.white.opacity(isActive ? 1 : 0.75))
                        .frame(width: isActive ? 40 : 6, height: 6)
                }
            }
            .animation(Self.tickSpring, value: current)
        }
    }

    /// Slightly bouncy so the stretch feels physical, but settles quickly.
    private static let tickSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
}

struct HomeView: View {
    let onSelect: (Emotion) -> Void

    @State private var selectedEmotion: Emotion = .stressed
    @State private var showAccountSheet: Bool = false

    var body: some View {
        ZStack {
            EmotionBackgroundView(emotion: selectedEmotion)

            TabView(selection: $selectedEmotion) {
                ForEach(Emotion.allCases, id: \.self) { emotion in
                    Color.clear
                        .tag(emotion)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            VStack {
                HStack {
                    Color.clear
                        .frame(width: 30, height: 30)
                        .glassEffect(.regular, in: AnimoLogoShape())
                    Spacer()
                    Button {
                        showAccountSheet = true
                    } label: {
                        // Same treatment as Parallel's profile button: the photo sits inside a glass circle.
                        Image("Animo_Profile_Pic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                            .frame(width: 48, height: 48)
                            .glassEffect(.regular.interactive(), in: .circle)
                            .contentShape(Circle())
                    }
                    .accessibilityLabel("Your profile")
                    .buttonStyle(.plain)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.horizontal, AppSpacing.screenMargin)
                
                Spacer()

                // The word sits dead center on the screen; the question hangs just above its letters, so it
                // stays a fixed, tight distance away whichever word is showing.
                EmotionLabel(emotion: selectedEmotion)
                    .padding(.horizontal, AppSpacing.screenMargin)
                    .overlay(alignment: .top) {
                        Text("How are you feeling?")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.textPrimary)
                            .fixedSize()
                            // The box has about 26pt of empty space above the letters; this leaves ~20pt between.
                            .offset(y: -12)
                    }
                    .allowsHitTesting(false)
                Spacer()

                VStack {
                    PageIndicator(
                        total: Emotion.allCases.count,
                        current: Emotion.allCases.firstIndex(of: selectedEmotion) ?? 0,
                        glass: true
                    )
                    .padding(.bottom, 12)

                    // Primary CTA: same black glass as the onboarding buttons.
                    PrimaryButton(title: "Select", style: .black) {
                        onSelect(selectedEmotion)
                    }
                    .padding(.horizontal, AppSpacing.screenMargin)
                    .padding(.bottom, AppSpacing.screenMargin)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .sheet(isPresented: $showAccountSheet) {
            HomeAccountSheet()
                .presentationDetents([.large])
                .presentationBackground(AppColor.bg)
                .presentationDragIndicator(.visible)
        }
    }
}

private struct EmotionLabel: View {
    let emotion: Emotion

    var body: some View {
        // The middle of the word's visible letters (not its text box) sits in the middle of the box, both across
        // and down, so each font's own spacing doesn't push it off-center and the question above never moves.
        ZStack {
            AnimatedEmotionWord(emotion: emotion)
                .alignmentGuide(HorizontalAlignment.center) { d in
                    d[.leading] + emotion.wordInkMetrics.ink.midX
                }
                .alignmentGuide(VerticalAlignment.center) { d in
                    // `ink` is measured from the baseline, y up.
                    d[.firstTextBaseline] - emotion.wordInkMetrics.ink.midY
                }
                // A new word replays its own entrance; the old one just gets out of the way quickly.
                .id(emotion)
                .transition(.asymmetric(insertion: .identity, removal: .opacity))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 96)
        .animation(.easeOut(duration: 0.15), value: emotion)
        .accessibilityElement()
        .accessibilityLabel(emotion.displayName)
    }
}

extension Emotion {
    var displayName: String {
        switch self {
        case .angry: return "Angry"
        case .stressed: return "Stressed"
        case .anxious: return "Anxious"
        case .tired: return "Tired"
        case .happy: return "Happy"
        }
    }
}

#Preview {
    HomeView(onSelect: { emotion in
        print("Preview selected:", emotion)
    })
}
