
import SwiftUI

struct IntensityDotsView: View {
    let emotion: Emotion

    var body: some View {
        Image("intensity_dots")
            .resizable()
            .scaledToFit()
            .foregroundStyle(emotion.color)
            .accessibilityLabel("Intensity")
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        IntensityDotsView(emotion: .stressed)
            .padding(40)
    }
}
