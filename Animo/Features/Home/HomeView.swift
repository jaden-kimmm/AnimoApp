
import SwiftUI

struct PageIndicator: View {
    let total: Int
    let current: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<total, id: \.self) { index in
                if index == current {
                    Capsule()
                        .fill(Color.white)
                        .frame(width: 40, height: 6)
                } else {
                    Circle()
                        .fill(Color.white.opacity(0.75))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}

struct HomeView: View {
    let onSelect: (Emotion) -> Void

    @State private var selectedEmotion: Emotion = .anxious
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
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(AppColor.black)
                        .frame(width: 30, height: 30)
                    Spacer()
                    Button {
                        showAccountSheet = true
                    } label: {
                        Image("Animo_Profile_Pic")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 16)
                .padding(.horizontal, 24)
                
                Spacer()

                VStack(spacing: 12) {
                    Text("How are you feeling?")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.black)

                    EmotionLabel(emotion: selectedEmotion)
                        .padding(.horizontal, 24)
                }
                .allowsHitTesting(false)
                Spacer()

                VStack {
                    PageIndicator(
                        total: Emotion.allCases.count,
                        current: Emotion.allCases.firstIndex(of: selectedEmotion) ?? 0
                    )
                    .padding(.bottom, 12)
                    
                    PrimaryButton(title: "Select", style: .black) {
                        onSelect(selectedEmotion)
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
                }

            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        }
        .sheet(isPresented: $showAccountSheet) {
            HomeAccountSheet()
                .presentationDetents([.height(790)])
                .presentationCornerRadius(47)
                .presentationDragIndicator(.visible)
        }
    }
}

private struct EmotionLabel: View {
    let emotion: Emotion

    var body: some View {
        Text(emotion.displayName)
            .textStyle(.display)
            .foregroundStyle(AppColor.black)
            .multilineTextAlignment(.center)
            .id(emotion)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.35), value: emotion)
            .modifier(BlurFade(emotion: emotion))
    }
}

private struct BlurFade: ViewModifier {
    let emotion: Emotion
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .blur(radius: isVisible ? 0 : 10)
            .opacity(isVisible ? 1 : 0)
            .onAppear {
                isVisible = true
            }
            .onChange(of: emotion) { _, _ in
                isVisible = false
                withAnimation(.easeInOut(duration: 0.35)) {
                    isVisible = true
                }
            }
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
