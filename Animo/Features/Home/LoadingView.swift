
import SwiftUI

struct LoadingView: View {
    let emotion: Emotion
    @State private var animate = false

    var body: some View {
        ZStack {
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Text("I’m prepping your run...")
                    .textStyle(.headline)
                    .foregroundStyle(AppColor.black.opacity(0.7))
                HStack(spacing: 10) {
                    ForEach(0..<3) { i in
                        Circle()
                            .fill(AppColor.black)
                            .frame(width: 10, height: 10)
                            .scaleEffect(animate ? 1.0 : 0.6)
                            .opacity(animate ? 1.0 : 0.4)
                            .animation(
                                .easeInOut(duration: 0.45)
                                .repeatForever()
                                .delay(Double(i) * 0.15),
                                value: animate
                            )
                    }
                }
            }
        }
        .onAppear { animate = true }
    }
}

#Preview {
    LoadingView(emotion: .happy)
}
