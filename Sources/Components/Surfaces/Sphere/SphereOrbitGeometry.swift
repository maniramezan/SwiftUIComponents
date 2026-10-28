import CoreGraphics
import Foundation
import OSLog

nonisolated enum SphereOrbitGeometry {
    struct Placement {
        let offset: CGPoint
        let scale: Double
        let depth: Double
    }

    struct Orientation {
        let pitch: Double
        let roll: Double
    }

    struct Pose {
        let turns: Double
        let orientation: Orientation
    }

    static let logger = Logger(subsystem: "com.swiftuicomponents", category: "OrbitingSphere")
    static let ringRadiusRatio = 0.38
    static let spatialRadiusRatio = 0.30
    static let cameraDistance = 4.5
    static let pitchRate = 0.37
    static let rollRate = 0.23
    static let pathSamples = 72

    static func canvasSize(width: CGFloat?, height: CGFloat?, idealSide: CGFloat) -> CGSize {
        let finiteWidth = width.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
        let finiteHeight = height.flatMap { $0.isFinite && $0 >= 0 ? $0 : nil }
        return CGSize(width: finiteWidth ?? finiteHeight ?? idealSide, height: finiteHeight ?? finiteWidth ?? idealSide)
    }

    static func phase(_ radians: Double) -> Double {
        guard radians.isFinite else {
            logger.fault("Invalid orbit phase; using the top of the orbit")
            return -.pi / 2
        }
        return radians
    }

    static func shouldAnimate(
        requested: Bool, reduceMotion: Bool, voiceOver: Bool, sceneActive: Bool, hasItems: Bool
    ) -> Bool {
        requested && !reduceMotion && !voiceOver && sceneActive && hasItems
    }

    static func uniqueItems<Item: Identifiable>(_ items: [Item]) -> [Item] {
        var seen: Set<Item.ID> = []
        return items.filter { item in
            guard seen.insert(item.id).inserted else {
                logger.fault("Duplicate orbit item identity; ignoring the repeated item")
                return false
            }
            return true
        }
    }

    static func positive<Value: BinaryFloatingPoint>(_ value: Value?, fallback: Value) -> Value {
        guard let value else { return fallback }
        guard value.isFinite, value > 0 else {
            logger.fault("Invalid sphere dimension or duration; using the theme default")
            return fallback
        }
        return value
    }

    static func orientation(
        elapsed: TimeInterval, revolutionDuration: TimeInterval,
        pitch: SphereOrbitTilt = .defaultPitch, roll: SphereOrbitTilt = .defaultRoll
    ) -> Orientation {
        Orientation(
            pitch: tiltAngle(pitch, elapsed: elapsed, fallbackDuration: revolutionDuration / pitchRate),
            roll: tiltAngle(roll, elapsed: elapsed, fallbackDuration: revolutionDuration / rollRate)
        )
    }

    static func pose(elapsed: TimeInterval, revolutionDuration: TimeInterval, motion: SphereOrbitMotion) -> Pose {
        Pose(
            turns: turns(elapsed: elapsed, duration: revolutionDuration),
            orientation: orientation(
                elapsed: elapsed, revolutionDuration: revolutionDuration, pitch: motion.pitch, roll: motion.roll
            )
        )
    }

    static func tiltAngle(_ tilt: SphereOrbitTilt, elapsed: TimeInterval, fallbackDuration: TimeInterval) -> Double {
        let duration = tilt.cycleDuration ?? fallbackDuration
        guard elapsed.isFinite, duration.isFinite, duration > 0 else { return tilt.center.radians }
        let progress = max(0, elapsed).truncatingRemainder(dividingBy: duration) / duration
        let angle = tilt.center.radians + tilt.amplitude.radians * sin(progress * 2 * .pi)
        return angle.isFinite ? angle : tilt.center.radians
    }

    static func placement(
        angle: Double, radius: CGFloat, style: SphereOrbitStyle, orientation: Orientation
    ) -> Placement {
        guard style == .spatial else {
            return Placement(offset: CGPoint(x: cos(angle) * radius, y: sin(angle) * radius), scale: 1, depth: 0)
        }
        let pitch = orientation.pitch
        let roll = orientation.roll
        let x = cos(angle)
        let z = sin(angle)
        let pitchedY = -z * sin(pitch)
        let depth = z * cos(pitch)
        let perspective = cameraDistance / (cameraDistance - depth)
        return Placement(
            offset: CGPoint(
                x: (x * cos(roll) - pitchedY * sin(roll)) * perspective * radius,
                y: (x * sin(roll) + pitchedY * cos(roll)) * perspective * radius
            ),
            scale: perspective,
            depth: depth
        )
    }

    static func turns(elapsed: TimeInterval, duration: TimeInterval) -> Double {
        guard elapsed.isFinite, duration.isFinite, duration > 0 else { return 0 }
        return max(0, elapsed) / duration
    }
}
