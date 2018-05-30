//
//  TennisMotionSampler.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/21/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import CoreMotion
import Common

class TennisMotionSampler: PMotionSampler {    
    
    var motionManager: CMMotionManager = CMMotionManager()
    var motionQueue: OperationQueue = OperationQueue()
    weak var delegate: MotionSamplerDelegate?

    var motionSamplesBuffer: PSamplingBuffer  = TennisSamplingBuffer(size: 50)
    
    var tennisSamplesBuffer: TennisSamplingBuffer {
        return motionSamplesBuffer as! TennisSamplingBuffer
    }
    
    var isSampling : Bool!
    
    // if crown is in the right side meaning the watch is in "normal" position
    // else the watch is upside down
    var watchHandSide : HandSide {
        return HandSide.left
    }
    
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
        }
    }
    
    /// PMotionSampler - handle sample data from watch
    func handleMotionData(_ motionData: [Double]) {
        //pull different measurements
        let tSample = TennisMotionSample(data: motionData)
        motionSamplesBuffer.addSample(tSample)
    }
    
    func handleFullBuffer() {
        guard isSampling,
            let tennisMLSample = tennisSamplesBuffer.calculateMLSampleData(for: watchHandSide.rawValue) else {
                return
        }
        
        delegate?.motionSampler(self, didSampleMotion: tennisMLSample)
        
        if abs(tennisSamplesBuffer.recentMean) < resetThreshold {
            tennisSamplesBuffer.reset()
        }
    }
    
    /// Method for parsing motion sample to Sample class
    ///
    /// - Parameter deviceMotion: performed motion
    internal func processDeviceMotion(_ motion: CMDeviceMotion) {
        handleMotionData([
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
            motion.userAcceleration.z])
        
        if motionSamplesBuffer.isFull {
            handleFullBuffer()
            return
        }
    }
}
