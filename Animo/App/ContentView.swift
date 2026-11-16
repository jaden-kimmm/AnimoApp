import SwiftUI

enum AppRoute {
    case landing
    case onboarding
    case home
    case loading
    case afterHome
    case running
    case afterRunComplete
}

struct ContentView: View {
    @State private var route: AppRoute = .landing
    @State private var selectedEmotion: Emotion = .stressed

    var body: some View {
        switch route {
        case .landing:
            LandingView(
                onStart: {
                    route = .onboarding
                },
                onLogin: {

                    print("Login tapped")
                }
            )

        case .onboarding:
            OnboardingFlowView {
                route = .home
            }

        case .home:
            HomeView(onSelect: { emotion in
                selectedEmotion = emotion
                route = .loading
            })
        case .loading:
            LoadingView(emotion: selectedEmotion)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        route = .afterHome
                    }
                }
        case .afterHome:
            SelectedRun(
                emotion: selectedEmotion,
                onBack: {
                    route = .home
                },
                onStart: {
                    route = .running
                }
            )

        case .running:
            RunningControl(
                emotion: selectedEmotion,
                onEnd: {
                    route = .afterRunComplete
                }
            )

        case .afterRunComplete:
            AfterRunComplete(
                emotion: selectedEmotion,
                onGoHome: {
                    route = .home
                }
            )
        }
    }
}

#Preview("Landing") {
    AppPreviewHost(startRoute: .landing)
}

#Preview("Onboarding") {
    AppPreviewHost(startRoute: .onboarding)
}

#Preview("Home") {
    AppPreviewHost(startRoute: .home)
}

#Preview("Loading") {
    AppPreviewHost(startRoute: .loading)
}

#Preview("AfterHome") {
    AppPreviewHost(startRoute: .afterHome)
}

#Preview("Running") {
    AppPreviewHost(startRoute: .running)
}

#Preview("AfterRunComplete") {
    AppPreviewHost(startRoute: .afterRunComplete)
}

private struct AppPreviewHost: View {
    @State private var route: AppRoute
    @State private var selectedEmotion: Emotion = .stressed

    init(startRoute: AppRoute) {
        _route = State(initialValue: startRoute)
    }

    var body: some View {
        ZStack {
            AppColor.bg.ignoresSafeArea()

            switch route {
            case .landing:
                LandingView(
                    onStart: { route = .onboarding },
                    onLogin: { print("Login tapped") }
                )

            case .onboarding:
                OnboardingFlowView {
                    route = .home
                }

            case .home:
                HomeView(onSelect: { emotion in
                    selectedEmotion = emotion
                    route = .loading
                })

            case .loading:
                LoadingView(emotion: selectedEmotion)

            case .afterHome:
                SelectedRun(
                    emotion: selectedEmotion,
                    onBack: {
                        route = .home
                    },
                    onStart: {
                        route = .running
                    }
                )

            case .running:
                RunningControl(
                    emotion: selectedEmotion,
                    onEnd: {
                        route = .afterRunComplete
                    }
                )

            case .afterRunComplete:
                AfterRunComplete(
                    emotion: selectedEmotion,
                    onGoHome: {
                        route = .home
                    }
                )
            }
        }
    }
}
