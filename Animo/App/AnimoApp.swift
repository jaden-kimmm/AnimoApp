

import SwiftUI

@main
struct AnimoApp: App {
    init() {
        // Segmented controls (the Latest Runs / Settings toggle) default to the system font; use the app's
        // Book weight at the label size instead.
        if let font = UIFont(name: "OverusedGrotesk-Book", size: 14) {
            UISegmentedControl.appearance().setTitleTextAttributes([.font: font], for: .normal)
            UISegmentedControl.appearance().setTitleTextAttributes([.font: font], for: .selected)
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                AppColor.bg
                    .ignoresSafeArea()

                ContentView()
                    .background(Color.clear)
            }
        }
    }
}

#Preview {
    ZStack {
        AppColor.bg
            .ignoresSafeArea()

        ContentView()
            .background(Color.clear)
    }
}
