//
//  AfterRunComplete.swift
//  Animo
//
//  Created by Jaden Kim on 12/30/25.
//

import SwiftUI

/// Figma 476:5243. Glass back + share buttons with "Run Complete" centered, the route filled in the
/// emotion color, a stats grid, and a Finish button.
struct AfterRunComplete: View {
    let emotion: Emotion
    let onGoHome: () -> Void

    var body: some View {
        ZStack {
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()

            AppColor.scrimLight
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                header
                    .padding(.bottom, 12)

                Text("You found joy!")
                    .textStyle(.display)
                    .foregroundStyle(AppColor.textPrimary)
                    .lineLimit(1)

                // Always shown in 3D here.
                Route3DView(emotion: emotion, route: .route1, alwaysIn3D: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.vertical, 16)

                stats

                PrimaryButton(title: "Finish", style: .black) {
                    onGoHome()
                }
                .padding(.top, 16)
            }
            .padding(.horizontal, AppSpacing.screenMargin)
            .padding(.bottom, AppSpacing.screenMargin)
        }
    }

    // MARK: - Sections

    /// Glass back + share circles with the title centered between them.
    private var header: some View {
        ZStack {
            Text("Run Complete")
                .textStyle(.body)
                .foregroundStyle(AppColor.textPrimary)

            HStack {
                Button {
                    onGoHome()
                } label: {
                    GlassCircleLabel(systemName: "arrow.left")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()

                ShareLink(item: "I just finished my Echo Park Run with Animo.") {
                    GlassCircleLabel(systemName: "square.and.arrow.up")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Share run")
            }
        }
    }

    private var stats: some View {
        Grid(alignment: .topLeading, horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                InfoCell(icon: "heart", label: "BPM", value: "133")
                InfoCell(icon: "speedometer", label: "Average Pace", value: "5.31 / mi")
            }
            GridRow {
                InfoCell(icon: "clock", label: "Total Time", value: "35:11")
                InfoCell(icon: "flame", label: "Total Calories", value: "621")
            }
            GridRow {
                InfoCell(
                    icon: "note.text",
                    label: "A Note",
                    value: "Your heart rate stabilized and your pace climbed. You're leaving the park better than you entered it.",
                    valueStyle: .label
                )
                .gridCellColumns(2)
            }
        }
    }
}

#Preview {
    AfterRunComplete(
        emotion: .stressed,
        onGoHome: { }
    )
}
