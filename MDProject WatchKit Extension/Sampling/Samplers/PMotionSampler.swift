
import Foundation
import CoreMotion

protocol MotionSamplerDelegate : class {
}

protocol PMotionSampler : class {
    var motionManager : CMMotionManager { set get }
    var motionQueue : OperationQueue { set get }
    var motionSamplesBuffer : PSamplingBuffer { get }
    var delegate: MotionSamplerDelegate? { set get }
    func startSampling()
    func stopSampling()
    func reset()
    func handleMotionData(_ motionData : [Double])
    func handleFullBuffer()
}

// Sampling Rate - 50hz
internal let sampleInterval : Double = 1.0 / 50
// These constants were derived from data and should be further tuned for your needs.
internal let yawThreshold = 1.95 // Radians
internal let rateThreshold = 5.5    // Radians/sec
internal let resetThreshold = 5.5 * 0.05 // To avoid double counting on the return swing.
