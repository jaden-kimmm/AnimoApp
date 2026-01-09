
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
            
            Color.white
                .opacity(0.55)
                .ignoresSafeArea()

            VStack {
            // Top
            HStack {
                Button {
                    onBack()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 14, weight: .regular))

                        Text("back")
                            .textStyle(.label)
                    }
                    .foregroundStyle(AppColor.lightWhiteText)
                }
                .buttonStyle(.plain)
                
                Spacer()
            }

            Spacer()
            
            HStack{
                Text("Los Angeles, CA")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.blackText)
                Spacer()
                
                
            }
            
            Spacer()
            
            HStack{
                Text("Echo Park Run")
                    .textStyle(.display)
                    .foregroundStyle(emotion.color)
                Spacer()
                
                
            }
            
            Spacer()
            
            VStack(spacing: 10) {
                Image("Echo_Park_Run_Bg")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .topLeading) {
                        Text(page == 0 ? "Route" : "Intensity")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.white)
                            .blurFade(active: true, trigger: page)
                            .padding(.top, 32)
                            .padding(.leading, 32)
                    }
                    .overlay {
                        ZStack {
                            if page == 0 {
                                RouteGradientView(emotion: emotion, route: .route1)
                                    .padding(24)
                                    .blurFade(active: true, trigger: page)
                            } else {
                                IntensityDotsView(emotion: emotion)
                                    .padding(24)
                                    .blurFade(active: true, trigger: page)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .overlay(alignment: .bottom) {
                        PageIndicator(total: 2, current: page)
                            .padding(.bottom, 24)
                    }
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture(minimumDistance: 10)
                            .onEnded { value in
                                if value.translation.width <= -swipeThreshold {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        page = 1
                                    }
                                } else if value.translation.width >= swipeThreshold {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        page = 0
                                    }
                                }
                            }
                    )
                
            }
            
            Spacer()
            
            HStack{
                VStack(alignment: .leading) {
                    Text("Weather")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("68°F, Clear")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Surface")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("Pavement")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                
            }
            
            Spacer()
            
            HStack{
                VStack(alignment: .leading) {
                    Text("Distance")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("3.2 mi")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Duration")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("28 min")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                
            }
            Spacer()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("A Note")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("I've kept the pace light today because you're feeling fried. No hills, just a steady rhythm to help you reset.")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                Spacer()
            }
            
            Spacer()
            
            
            
            PrimaryButton(title: "Start", style: .black) {
                onStart()
            }
            
            

            
            }
            .padding(24)
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
