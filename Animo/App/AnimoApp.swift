

import SwiftUI

@main
struct AnimoApp: App {
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
