import Foundation

/// One finished run, as shown in the profile sheet's Latest Runs list and its detail screen.
/// All sample data for now.
struct RunSummary: Identifiable, Hashable {
    let id: String
    let title: String
    let location: String
    let month: String
    /// Photo asset name.
    let imageName: String
    let route: RouteShape
    let emotion: Emotion

    // Stats
    let bpm: Int
    let pace: String
    let time: String
    let calories: Int

    // Detail
    let weather: String
    let surface: String
    let distance: String
    let note: String

    static let samples: [RunSummary] = [
        RunSummary(
            id: "arts-district", title: "Arts District Run", location: "Los Angeles, CA", month: "October 2024",
            imageName: "Arts_District_Run", route: .route5, emotion: .angry,
            bpm: 148, pace: "6:12 / mi", time: "29:41", calories: 540,
            weather: "72°F, Sunny", surface: "Pavement", distance: "4.8 mi",
            note: "You were fired up, so I let you push the pace early. Strong finish."
        ),
        RunSummary(
            id: "echo-park", title: "Echo Park Run", location: "Los Angeles, CA", month: "October 2024",
            imageName: "Echo_Park_Run", route: .route1, emotion: .stressed,
            bpm: 132, pace: "5:58 / mi", time: "31:09", calories: 505,
            weather: "68°F, Clear", surface: "Pavement", distance: "3.2 mi",
            note: "I've kept the pace light today because you're feeling fried. No hills, just a steady rhythm to help."
        ),
        RunSummary(
            id: "griffith-park", title: "Griffith Park Run", location: "Los Angeles, CA", month: "September 2024",
            imageName: "Griffith_Park_Run", route: .route2, emotion: .anxious,
            bpm: 141, pace: "6:05 / mi", time: "34:02", calories: 612,
            weather: "75°F, Breezy", surface: "Trail", distance: "5.6 mi",
            note: "Trails keep your mind on your feet. Your breathing settled by the second mile."
        ),
        RunSummary(
            id: "santa-monica", title: "Santa Monica Run", location: "Santa Monica, CA", month: "September 2024",
            imageName: "Santa_Monica_Run", route: .route3, emotion: .tired,
            bpm: 137, pace: "5:44 / mi", time: "28:33", calories: 498,
            weather: "66°F, Overcast", surface: "Boardwalk", distance: "5.0 mi",
            note: "Flat and easy by the water, which is what a tired day needs."
        ),
        RunSummary(
            id: "silver-lake", title: "Silver Lake Run", location: "Los Angeles, CA", month: "August 2024",
            imageName: "Silver_Lake_Run", route: .route4, emotion: .happy,
            bpm: 153, pace: "6:22 / mi", time: "27:18", calories: 560,
            weather: "78°F, Clear", surface: "Pavement", distance: "4.3 mi",
            note: "You were feeling great, so we ran loops around the reservoir for the fun of it."
        )
    ]
}
