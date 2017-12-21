//
//  TennisMotionSampler.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/21/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import CoreMotion

class TennisMotionSampler: PMotionSampler {    
    
    var motionManager: CMMotionManager = CMMotionManager()
    var motionQueue: OperationQueue = OperationQueue()
    weak var delegate: MotionSamplerDelegate?
    
    var tennisSamplesBuffer: TennisSamplingBuffer = TennisSamplingBuffer(size: 50)
    var motionSamplesBuffer: PSamplingBuffer {
        return tennisSamplesBuffer
    }
    
    var startTime : Date = Date()
    
    init() {
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionQueue.maxConcurrentOperationCount = 1
        motionQueue.name = "MotionManagerQueue"
    }
    
    
    /// PMotionSampler - start sampling from watch
    func startSampling() {
        // Checks for motion manager availability
        guard motionManager.isDeviceMotionAvailable else {
            print("Device Motion is not available.")
            return
        }
        reset()
        motionManager.deviceMotionUpdateInterval = sampleInterval
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startAccelerometerUpdates()
        motionManager.startDeviceMotionUpdates(to: motionQueue) { (deviceMotion: CMDeviceMotion?, error: Error?) in
            if error != nil {
                print("Encountered error: \(error!)")
            }
            if deviceMotion != nil {
                self.processDeviceMotion(deviceMotion!)
            }
        }
    }
    
    /// PMotionSampler - stop sampling from watch
    func stopSampling() {
        if motionManager.isDeviceMotionAvailable {
            //            delegate?.motionSampler(self, storeMotionSamples: arrSamples)
            // clean motion queue
            motionQueue.cancelAllOperations()
            // stop motionUpdates
            motionManager.stopDeviceMotionUpdates()
            reset()
        }
    }
    
    func reset() {
        
    }
    
    /// PMotionSampler - handle sample data from watch
    func handleMotionData(_ motionData: [Double]) {
        //pull different measurements
        let tSample = TennisMotionSample(data: motionData)
        motionSamplesBuffer.addSample(tSample)
    }
    
    func handleFullBuffer() {}
    
    /// Method for parsing motion sample to Sample class
    ///
    /// - Parameter deviceMotion: performed motion
    internal func processDeviceMotion(_ motion: CMDeviceMotion) {
        guard motionSamplesBuffer.isFull() == false else {
            handleFullBuffer()
            return
        }
        handleMotionData([
            Date().timeIntervalSince(startTime),
            motion.rotationRate.x,
            motion.rotationRate.y,
            motion.rotationRate.z,
            motion.gravity.x,
            motion.gravity.y,
            motion.gravity.z,
            motion.attitude.pitch,
            motion.attitude.roll,
            motion.attitude.yaw,
            motion.userAcceleration.x,
            motion.userAcceleration.y,
            motion.userAcceleration.z,
            motion.magneticField.field.x,
            motion.magneticField.field.x,
            motion.magneticField.field.x,
            Double(motion.magneticField.accuracy.rawValue)])
    }
}