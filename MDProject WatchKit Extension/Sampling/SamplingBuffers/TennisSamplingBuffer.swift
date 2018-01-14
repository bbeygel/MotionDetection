//
//  TennisSamplingBuffer.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/20/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit

class TennisSamplingBuffer: PSamplingBuffer {
    
    // FIX: - make the buffer as stack to be able to check last 50 sasmples
    var buffer: [Double] {
        return data.map {
            return  $0.rotationX * $0.gravityX +
                    $0.rotationY * $0.gravityY +
                    $0.rotationZ * $0.gravityZ
        }
    }
    
    internal var data: [MotionSample] = [MotionSample]() {
        didSet {
            if data.count > size {
                data.removeLast()
            }
        }
    }
    internal var size: Int
    
    // MARK: Initialization
    required init(size: Int) {
        
        self.size = size
    }
    
    // MARK: Running Buffer
    func addSample(_ sample: MotionSample) {
        data.insert(sample, at:0)
        if data.count > size  {
            data.removeLast()
        }
    }
    func removeLastSample() {
        data.removeLast()
    }
    func reset() {
        data.removeAll()
    }
    // MARK: - Sampling Functions
    func calculateMLSampleData(for hand : Int) -> TennisMLSample {
        let accumulatedYawRotation = self.sum * sampleInterval
        let peakRate = accumulatedYawRotation > 0 ? self.max : self.min
        let passedYawThreshold = accumulatedYawRotation > yawThreshold
        let passedNegativeYawThreshold = accumulatedYawRotation < -yawThreshold
        let passedPeakRateThreshold = peakRate > rateThreshold
        let passedNegativePeakRateThreshold = peakRate < -rateThreshold
        
        let sampleData = TennisMLSample(timestamp: Int(Date().timeIntervalSince1970),
                                        hand: hand,
                                        peakRate: peakRate,
                                        passedYawTreshold: passedYawThreshold,
                                        passedNegativeYawTreshold: passedNegativeYawThreshold,
                                        passedPeakRateThreshold: passedPeakRateThreshold,
                                        passedNegativePeakRateThreshold: passedNegativePeakRateThreshold)
        switch sampleData.classification {
        case MotionType.backhand.rawValue: reset(); break
        case MotionType.forhand.rawValue: reset(); break
        default: break
        }
        return sampleData;
    }
    
    
    var isFull : Bool {
        return size == data.count
    }
    
    var sum : Double {
        return buffer.reduce(0.0, +)
    }
    
    var min : Double {
        var min = Double.leastNormalMagnitude
        if let minBuffer = buffer.min() {
            min = minBuffer
        }
        return min
    }
    
    var max : Double {
        var max = Double.greatestFiniteMagnitude
        if let maxBuffer = buffer.max() {
            max = maxBuffer
        }
        return max
    }
    
    var recentMean : Double {
        // Calculate the mean over the beginning half of the buffer.
        let recentCount = self.size / 2
        var mean = 0.0
        
        if (buffer.count >= recentCount) {
            let recentBuffer = buffer[0..<recentCount]
            mean = recentBuffer.reduce(0.0, +) / Double(recentBuffer.count)
        }
        return mean
    }
}
