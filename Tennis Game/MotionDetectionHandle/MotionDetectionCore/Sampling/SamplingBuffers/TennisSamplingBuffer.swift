//
//  TennisSamplingBuffer.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/20/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import Common

class TennisSamplingBuffer: SamplingBuffer {
    
    override var buffer: [Double] {
        return data.map {
            return  $0.rotationX * $0.gravityX +
                    $0.rotationY * $0.gravityY +
                    $0.rotationZ * $0.gravityZ
        }
    }
    
    // MARK: - Sampling Functions
    func calculateMLSampleData(for hand : Int) -> TennisMLSample {
        let accumulatedYawRotation = self.sum * sampleInterval
        let peakRate = accumulatedYawRotation > 0 ? self.max : self.min
        let accelSum = data.map { return $0.accelerationZ + $0.accelerationY + $0.accelerationX }.reduce(0.0, +)
        
        let sampleData = TennisMLSample(timestamp: Int(Date().timeIntervalSince1970),
                                        hand: hand,
                                        peakRate: peakRate,
                                        accumulatedYawRotation: accumulatedYawRotation,
                                        yawThreshold: yawThreshold,
                                        rateThreshold: rateThreshold,
                                        accelSum:accelSum)
        switch sampleData.classification {
        case MotionType.backhand.rawValue: reset(); break
        case MotionType.forhand.rawValue: reset(); break
        default: break
        }
        if sampleData.classification != MotionType.none.rawValue {
            print("classification: \(sampleData.classification)\ntimestamp: \(sampleData.timestamp)\n AccelSum: \(accelSum)--------------\n")
        }
        return sampleData;
    }
}
