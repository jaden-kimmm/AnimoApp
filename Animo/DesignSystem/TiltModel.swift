import CoreMotion
import Foundation

/// How far the phone is tilted, as `roll` (left/right) and `pitch` (forward/back) in radians.
///
/// Whatever angle the phone is held at when `start()` is called counts as level. Values ease towards the
/// latest reading each time `step()` is called (once per frame), so the motion stays smooth.
/// Device motion isn't available in the Simulator, so `setTarget(roll:pitch:)` lets a drag stand in for it.
final class TiltModel {
    /// Largest tilt reported, in radians (about 34 degrees).
    static let maxTilt: Double = 0.6

    private(set) var roll: Double = 0
    private(set) var pitch: Double = 0

    private var targetRoll: Double = 0
    private var targetPitch: Double = 0
    /// How much of the remaining distance to the target is covered each frame: lower = smoother but laggier.
    private let smoothing: Double = 0.18

    private let manager = CMMotionManager()
    private var reference: CMAttitude?

    func start() {
        guard manager.isDeviceMotionAvailable, !manager.isDeviceMotionActive else { return }
        manager.deviceMotionUpdateInterval = 1.0 / 60.0
        manager.startDeviceMotionUpdates(using: .xArbitraryZVertical, to: .main) { [weak self] motion, _ in
            guard let self, let attitude = motion?.attitude else { return }
            guard let reference = self.reference else {
                self.reference = attitude.copy() as? CMAttitude
                return
            }
            attitude.multiply(byInverseOf: reference)
            self.setTarget(roll: attitude.roll, pitch: attitude.pitch)
        }
    }

    func stop() {
        manager.stopDeviceMotionUpdates()
        reference = nil
        setTarget(roll: 0, pitch: 0)
    }

    /// Sets where the tilt should head to (radians; clamped to `maxTilt`).
    func setTarget(roll: Double, pitch: Double) {
        targetRoll = min(max(roll, -Self.maxTilt), Self.maxTilt)
        targetPitch = min(max(pitch, -Self.maxTilt), Self.maxTilt)
    }

    /// Moves `roll` and `pitch` a step closer to the target. Call once per frame.
    func step() {
        roll += (targetRoll - roll) * smoothing
        pitch += (targetPitch - pitch) * smoothing
    }
}
