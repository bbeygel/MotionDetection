
import Foundation
import CoreMotion

protocol MotionSamplerDelegate: class {
    func motionSampler(_ sampler : MotionSampler, storeMotionSamples samples : [MotionSampler.Sample])
    func motionSampler(_ sampler : MotionSampler, updateActionLabel label : String)
    func motionSampler(_ sampler : MotionSampler, updateTimerLabel label : String)
}

// 50hz
private let sampleInterval : Double = 1.0 / 50

class MotionSampler: NSObject {
    
    /// static vars + getters
    static lazy let shared : MotionSampler()
    
    /// class properties
    weak var delegate: MotionSamplerDelegate?
    
    private let motionManager = CMMotionManager()
    private let motionQueue = OperationQueue()
    
    private var arrSamples = [Sample]()
    var startTime : Date = Date()
    
    
    private init?() {
        // Checks for motion manager availability
        // else returns nil
        guard motionManager.isDeviceMotionAvailable == true else {
            print("Device Motion is not available.")
            return nil
        }
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionQueue.maxConcurrentOperationCount = 1
        motionQueue.name = "MotionManagerQueue"
    }
    
    
    
    // MARK: WorkoutManager
    func startSampling() {
        
        sharedSampler.motionManager.startGyroUpdates()
        sharedSampler.motionManager.startMagnetometerUpdates()
        sharedSampler.motionManager.startAccelerometerUpdates()
        sharedSampler.motionManager.startDeviceMotionUpdates(to: motionQueue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
        
    }
    
    func stopSampling() {
        if motionManager.isDeviceMotionAvailable {
            delegate?.motionSampler(self, storeMotionSamples: arrSamples)
            // clean motion queue
            motionQueue.cancelAllOperations()
            // stop motionUpdates
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    
    /// Method for parsing motion sample to Sample class
    ///
    /// - Parameter deviceMotion: performed motion
    func processDeviceMotion(_ deviceMotion: CMDeviceMotion) {
        //pull different measurements
        let sample = Sample(data: [
            Date().timeIntervalSince(startTime),
            deviceMotion.rotationRate.x,
            deviceMotion.rotationRate.y,
            deviceMotion.rotationRate.z,
            deviceMotion.gravity.x,
            deviceMotion.gravity.y,
            deviceMotion.gravity.z,
            deviceMotion.attitude.pitch,
            deviceMotion.attitude.roll,
            deviceMotion.attitude.yaw,
            deviceMotion.userAcceleration.x,
            deviceMotion.userAcceleration.y,
            deviceMotion.userAcceleration.z,
            deviceMotion.magneticField.field.x,
            deviceMotion.magneticField.field.x,
            deviceMotion.magneticField.field.x,
            Double(deviceMotion.magneticField.accuracy.rawValue)])
            
            //append row to 2d array of measurements
            arrSamples.append(sample)
            
            if arrSamples.count % 500 == 0 {
                delegate?.motionSampler(self, storeMotionSamples: arrSamples)
                arrSamples.removeAll()
        }
    }
    
    func measureUpdateDelegate(measurementsArr:[Sample]) {
        delegate?.motionSampler(self, storeMotionSamples: arrSamples)
    }
}
