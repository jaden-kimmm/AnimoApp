//
//  HomeAccountSheet.swift
//  Animo
//
//  Created by Jaden Kim on 12/30/25.
//

import SwiftUI

struct HomeAccountSheet: View {
    @Environment(\.dismiss) private var dismiss

    private enum SheetTab {
        case latestRuns
        case settings
    }

    @State private var tab: SheetTab = .latestRuns

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 24)
                .padding(.top, 24)

            tabBar
                .padding(.horizontal, 24)
                .padding(.top, 12)

            Group {
                switch tab {
                case .latestRuns:
                    latestRunsContent
                case .settings:
                    settingsContent
                }
            }
            .padding(.top, 18)

            Spacer(minLength: 0)
        }
        .background(AppColor.bg)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Image("Animo_Profile_Pic")
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(Circle())

            VStack(spacing: 0) {
                Text("Jaden Kim")
                    .textStyle(.display)
                    .foregroundStyle(AppColor.black)
                    .multilineTextAlignment(.center)

                Text("Experienced Runner")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.black)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var tabBar: some View {
        HStack(spacing: 28) {
            Spacer()
            tabItem(title: "Latest Runs", tab: .latestRuns)
            tabItem(title: "Settings", tab: .settings)
            Spacer()
        }
    }

    private func tabItem(title: String, tab: SheetTab) -> some View {
        let isSelected = self.tab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                self.tab = tab
            }
        } label: {
            VStack(spacing: 6) {
                Text(title)
                    .textStyle(.label)
                    .foregroundStyle(isSelected ? AppColor.black : AppColor.lightWhiteText)

                Rectangle()
                    .fill(isSelected ? AppColor.black : Color.clear)
                    .frame(height: 2)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .buttonStyle(.plain)
    }

    // Demo: swipeable peek cards (white rounded rectangles)
    private var latestRunsContent: some View {
        VStack(spacing: 24) {
            GeometryReader { geo in
                let availableWidth = geo.size.width
                let peek: CGFloat = 14            // neighbor peek on EACH side
                let spacing: CGFloat = 0          // honest spacing BETWEEN cards
                let overlap: CGFloat = 5          // visual overlap amount (positive number)
                let cardWidth = availableWidth - (peek * 2)
                let sideInset: CGFloat = peek     // enough inset so first/last can center
                let bgNames = ["Arts_District_Run", "Echo_Park_Run", "Griffith_Park_Run", "Santa_Monica_Run", "Silver_Lake_Run"]
                let locations = ["Los Angeles, CA", "Los Angeles, CA", "Los Angeles, CA", "Santa Monica, CA", "Los Angeles, CA"]
                let titles = ["Arts District Run", "Echo Park Run", "Griffith Park Run", "Santa Monica Run", "Silver Lake Run"]
                let bpms = [148, 132, 141, 137, 153]
                let paces = ["6:12 / mi", "5:58 / mi", "6:05 / mi", "5:44 / mi", "6:22 / mi"]
                let times = ["29:41", "31:09", "34:02", "28:33", "27:18"]
                let calories = [540, 505, 612, 498, 560]
                let routes: [RouteShape] = [.route1, .route2, .route3, .route4, .route5]
                let emotions: [Emotion] = [.angry, .stressed, .anxious, .tired, .happy]

                ScrollView(.horizontal) {
                    LazyHStack(spacing: spacing) {
                        ForEach(0..<bgNames.count, id: \.self) { i in
                            ZStack {
                                Image(bgNames[i])
                                    .resizable()
                                    .scaledToFill()          // FILL, not FIT
                                    .frame(width: cardWidth, height: geo.size.height)
                                    .clipped()
                                    .overlay {
                                        Color.black.opacity(0.18)
                                    }

                                VStack(alignment: .leading, spacing: 0) {
                                    // Top labels
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(locations[i])
                                            .textStyle(.label)
                                            .foregroundColor(AppColor.white)
                                        Text(titles[i])
                                            .textStyle(.headline)
                                            .foregroundColor(AppColor.white)
                                    }

                                    

                                    RouteGradientView(emotion: emotions[i], route: routes[i])


                                    

                                    // Bottom metrics
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack{
                                            metricBlock(title: "BPM", value: "\(bpms[i])")
                                            metricBlock(title: "Average Pace", value: paces[i])
                                        }
                                        HStack{
                                            metricBlock(title: "Total Time", value: times[i])
                                            metricBlock(title: "Total Calories", value: "\(calories[i])")
                                        }
                                    }
                                }
                                .padding(.horizontal, 42)
                                .padding(.vertical, 32)
                            }
                            
                            .clipShape(RoundedRectangle(cornerRadius: 47, style: .continuous))
                            .scrollTransition(.interactive, axis: .horizontal) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.95)
                                    .offset(x: phase.isIdentity ? 0 : (-phase.value * overlap))
                                    .opacity(phase.isIdentity ? 1.0 : 0.85)
                                
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .scrollIndicators(.hidden)
                .contentMargins(.horizontal, sideInset, for: .scrollContent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            

            PrimaryButton(title: "Share", style: .black) {
                // demo
            }
            .padding(.horizontal, 24)
        }
    }

    private func metricBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .textStyle(.label)
                .foregroundColor(AppColor.lightWhiteText)

            Text(value)
                .textStyle(.label)
                .foregroundColor(AppColor.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var settingsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {

                Text("Account")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.black)
                    .padding(.horizontal, 24)

                settingsCard(rows: [
                    "Email",
                    "Phone Number",
                    "Language",
                    "Name",
                    "Security"
                ])

                Text("Personalization")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.black)
                    .padding(.horizontal, 24)

                settingsCard(rows: [
                    "Voice",
                    "Distance Priority",
                    "Time Priority",
                    "Route Preferences"
                ])
            }
            .padding(.top, 6)
            .padding(.bottom, 32)
        }
    }

    private func settingsCard(rows: [String]) -> some View {
        VStack(spacing: 0) {
            ForEach(rows.indices, id: \.self) { i in
                settingsRow(title: rows[i])

                if i != rows.indices.last {
                    Divider()
                        .overlay(AppColor.lightWhiteText.opacity(0.22))
                        .padding(.horizontal, 42)
                }
            }
        }
        .background(AppColor.white)
        .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
        .padding(.horizontal, 24)
    }

    private func settingsRow(title: String) -> some View {
        Button {
            // TODO: wire destinations
        } label: {
            HStack(spacing: 12) {
                Text(title)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.black)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(AppColor.black)
            }
            .padding(.horizontal, 42)
            .padding(.vertical, 18)
        }
        .buttonStyle(.plain)
    }
}

private struct HomeAccountSheetPreviewHost: View {
    @State private var showSheet = true

    var body: some View {
        ZStack {
            AppColor.black.opacity(0.05).ignoresSafeArea()
            Text("Home")
                .textStyle(.headline)
                .foregroundStyle(AppColor.black)
        }
        .sheet(isPresented: $showSheet) {
            HomeAccountSheet()
                .presentationDetents([.height(790)])
                .presentationCornerRadius(47)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    HomeAccountSheetPreviewHost()
}
