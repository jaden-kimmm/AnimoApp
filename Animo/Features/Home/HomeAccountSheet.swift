//
//  HomeAccountSheet.swift
//  Animo
//
//  Created by Jaden Kim on 12/30/25.
//

import SwiftUI
import Glur

struct HomeAccountSheet: View {
    @Environment(\.dismiss) private var dismiss

    private enum SheetTab: String, CaseIterable {
        case latestRuns = "Latest Runs"
        case settings = "Settings"
    }

    @State private var tab: SheetTab = .latestRuns
    /// The runs pushed on the stack: empty on the list, one entry while a run's detail is open.
    @State private var path: [RunSummary] = []

    var body: some View {
        // Tapping a run pushes its detail with the standard iOS push (slides in from the right). The detail
        // blocks every swipe that would leave it, so its back button is the only way out (see RunDetailView).
        NavigationStack(path: $path) {
            sheetContent
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: RunSummary.self) { run in
                    RunDetailView(runs: RunSummary.samples, run: run)
                }
        }
        // While a run is open, the sheet can't be swiped away either.
        .interactiveDismissDisabled(!path.isEmpty)
    }

    private var sheetContent: some View {
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
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)

                Text("Experienced Runner")
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
    }

    /// The standard segmented control (a glass capsule with a sliding pill on iOS 26).
    private var tabBar: some View {
        Picker("Section", selection: $tab.animation(.easeInOut(duration: 0.15))) {
            ForEach(SheetTab.allCases, id: \.self) { tab in
                Text(tab.rawValue).tag(tab)
            }
        }
        .pickerStyle(.segmented)
    }

    /// Swipeable cards, one per run: the photo and route with the date, place and name. Tap one to open it.
    private var latestRunsContent: some View {
        VStack(spacing: 24) {
            GeometryReader { geo in
                let peek: CGFloat = 14            // neighbor peek on EACH side
                let overlap: CGFloat = 5          // visual overlap amount (positive number)
                let cardWidth = geo.size.width - (peek * 2)

                ScrollView(.horizontal) {
                    LazyHStack(spacing: 0) {
                        ForEach(RunSummary.samples) { run in
                            NavigationLink(value: run) {
                                runCard(run, width: cardWidth, height: geo.size.height)
                            }
                            .buttonStyle(.plain)
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
                .contentMargins(.horizontal, peek, for: .scrollContent)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            PrimaryButton(title: "Share", style: .black) {
                // demo
            }
            .padding(.horizontal, 24)
        }
    }

    /// Figma 486:6819: month at the top, place and run name at the bottom, the route in between. The photo
    /// blurs progressively towards the bottom so the name stays readable.
    private func runCard(_ run: RunSummary, width: CGFloat, height: CGFloat) -> some View {
        ZStack {
            Image(run.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .overlay { AppColor.scrimDark }
                .glur(radius: 16, offset: 0.7, interpolation: 0.3, direction: .down)

            RouteView(emotion: run.emotion, route: run.route, style: .fill)
                .padding(.horizontal, 42)
                .padding(.vertical, 96)
                .frame(width: width, height: height)

            VStack(alignment: .leading, spacing: 0) {
                Text(run.month)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textOnDark)

                Spacer()

                Text(run.location)
                    .textStyle(.label)
                    .foregroundStyle(AppColor.textOnDark)
                Text(run.title)
                    .textStyle(.headline)
                    .foregroundStyle(AppColor.textOnDark)
            }
            .padding(32)
            .frame(width: width, height: height, alignment: .topLeading)
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 47, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 47, style: .continuous))
    }

    private let settingsSections: [(title: String, rows: [(title: String, icon: String)])] = [
        ("Account", [
            ("Email", "envelope"),
            ("Phone Number", "phone"),
            ("Language", "globe"),
            ("Name", "person.text.rectangle"),
            ("Security", "lock")
        ]),
        ("Personalization", [
            ("Voice", "waveform"),
            ("Distance Priority", "ruler"),
            ("Time Priority", "clock"),
            ("Route Preferences", "map")
        ])
    ]

    /// Standard grouped `List`: the system supplies the card corners, row heights, insets, separators
    /// and section-header spacing, so only colors, fonts and the side margin are customized.
    private var settingsContent: some View {
        List {
            ForEach(settingsSections, id: \.title) { section in
                Section {
                    ForEach(section.rows, id: \.title) { row in
                        settingsRow(title: row.title, icon: row.icon)
                            .listRowBackground(AppColor.white)
                            .listRowSeparatorTint(AppColor.separator)
                    }
                } header: {
                    Text(section.title)
                        .textStyle(.label)
                        .foregroundStyle(AppColor.textSecondary)
                        .textCase(nil)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .contentMargins(.horizontal, AppSpacing.screenMargin, for: .scrollContent)
    }

    private func settingsRow(title: String, icon: String) -> some View {
        Button {
            // TODO: wire destinations
        } label: {
            HStack(spacing: 16) {
                // Fixed width so every title lines up, whatever the symbol's own width.
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundStyle(AppColor.textPrimary)
                    .frame(width: 24)

                Text(title)
                    .textStyle(.body)
                    .foregroundStyle(AppColor.textPrimary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(AppColor.textSecondary)
            }
            .contentShape(Rectangle())
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
                .foregroundStyle(AppColor.textPrimary)
        }
        .sheet(isPresented: $showSheet) {
            HomeAccountSheet()
                .presentationDetents([.large])
                .presentationBackground(AppColor.bg)
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    HomeAccountSheetPreviewHost()
}
