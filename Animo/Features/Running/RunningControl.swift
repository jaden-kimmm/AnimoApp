
import SwiftUI

struct RunningControl: View {
    let emotion: Emotion
    let onEnd: () -> Void

    @State private var elapsedSeconds: Int = 12 * 60 + 44
    @State private var distanceMiles: Double = 2.40
    @State private var caloriesAcc: Double = 231.0
    @State private var turnDistanceFeet: Int = 500
    @State private var runTimer: Timer?
    @State private var isPaused: Bool = false

    var body: some View {
        ZStack{
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()
            
            Color.white
                .opacity(0.15)
                .ignoresSafeArea()
            
            VStack{
                HStack{
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.lightWhiteText)
                        Text("\(distanceMiles, specifier: "%.2f") mi")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.blackText)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Calories")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.lightWhiteText)
                        Text("\(Int(caloriesAcc)) kcal")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.blackText)
                    }
                    Spacer()
                    VStack(alignment: .leading) {
                        Text("Time Elapsed")
                            .textStyle(.label)
                            .foregroundStyle(AppColor.lightWhiteText)
                        Text(timeString(from: elapsedSeconds))
                            .textStyle(.label)
                            .foregroundStyle(AppColor.blackText)
                    }
                }
                
                RouteGradientRunningView(emotion: emotion)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .layoutPriority(1)
                    .padding(.vertical, 16)
                
                Spacer()
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "arrow.turn.up.left")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(emotion.color)
                        .frame(width: 44, height: 44)
                        .background(AppColor.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                    VStack(alignment: .leading, spacing: 10) {
                        Text("In \(turnDistanceFeet)ft, turn left")
                            .textStyle(.display)
                            .foregroundStyle(AppColor.blackText)

                        Text("Parkway Ave.")
                            .textStyle(.body)
                            .foregroundStyle(AppColor.blackText)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                HStack(spacing:6) {
                    Button {
                        stopSimulatedRunTimer()
                        isPaused = false
                        onEnd()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(AppColor.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 142)
                            .background(AppColor.white.opacity(0.50))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }

                    Button {
                        isPaused.toggle()

                        if isPaused {
                            stopSimulatedRunTimer()
                        } else {
                            startSimulatedRunTimer()
                        }
                    } label: {
                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(AppColor.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 142)
                            .background(AppColor.white.opacity(0.50))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .transaction { txn in
                                txn.animation = nil
                            }
                    }

                    Button { } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 24, weight: .regular))
                            .foregroundStyle(AppColor.white)
                            
                            .frame(maxWidth: .infinity)
                            .frame(height: 142)
                            .background(AppColor.white.opacity(0.50))
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 0)
            .onAppear {
                startSimulatedRunTimer()
            }
            .onDisappear {
                stopSimulatedRunTimer()
                isPaused = false
            }
        }
    }

    private func timeString(from seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startSimulatedRunTimer() {
        runTimer?.invalidate()

        runTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedSeconds += 1
            distanceMiles += 0.0021
            caloriesAcc += 0.17

            if elapsedSeconds % 20 == 0 {
                turnDistanceFeet = max(turnDistanceFeet - 50, 50)
            }
        }
    }

    private func stopSimulatedRunTimer() {
        runTimer?.invalidate()
        runTimer = nil
    }
}

#Preview {
    RunningControl(emotion: .stressed, onEnd: { })
}
