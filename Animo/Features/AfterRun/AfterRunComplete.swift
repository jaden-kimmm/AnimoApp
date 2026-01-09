//
//  AfterRunComplete.swift
//  Animo
//
//  Created by Jaden Kim on 12/30/25.
//

import SwiftUI

struct AfterRunComplete: View {
    let emotion: Emotion
    let onGoHome: () -> Void

    @State private var page: Int = 0

    private let swipeThreshold: CGFloat = 40

    var body: some View {
        ZStack {
            EmotionBackgroundView(emotion: emotion)
                .ignoresSafeArea()
            
            Color.white
                .opacity(0.55)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(AppColor.lightWhiteText)
                    
                    Text("Run Complete")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Spacer()
                }
            

            
            HStack{
                Text("Los Angeles, CA")
                    .textStyle(.label)
                    .foregroundStyle(AppColor.blackText)
                Spacer()
                
                
            }
            
            
            HStack{
                Text("You found joy!")
                    .textStyle(.display)
                    .foregroundStyle(emotion.color)
                Spacer()
                
                
            }
            
            
                
                RouteFillView(emotion: emotion, route: .route1)
                
                    
            
            
            
            HStack{
                VStack(alignment: .leading) {
                    Text("BPM")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("133")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Average Pace")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                        
                    Text("5.31 / mi")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                
            }
            
            
            HStack{
                VStack(alignment: .leading) {
                    Text("Total Time")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("35:11")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                VStack(alignment: .leading) {
                    Text("Total Calories")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("621")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
                
                
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text("A Note")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.lightWhiteText)
                    Text("Your heart rate stabilized and your pace climbed. You're leaving the park better than you entered it.")
                        .textStyle(.label)
                        .foregroundStyle(AppColor.blackText)
                }
                Spacer()
            }
            
            Spacer()
            
            
            
            PrimaryButton(title: "Finish", style: .black) {
                onGoHome()
            }
            
            
            

            
            }
            .padding(24)
        }
    }
}

#Preview {
    AfterRunComplete(
        emotion: .stressed,
        onGoHome: { }
    )
}
