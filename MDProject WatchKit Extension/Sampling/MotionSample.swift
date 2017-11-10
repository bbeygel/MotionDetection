//
//  MotionSample.swift
//  MotionDetection WatchKit Extension
//
//  Created by Yevgeny Beygel on 9/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation
extension MotionSampler {
    // Sample Struct for Sampler record
    class Sample : NSObject {
        
        enum SampleDataType : Int {
            case timeInterval = 0
            case rotationX
            case rotationY
            case rotationZ
            case gravityX
            case gravityY
            case gravityZ
            case pitch
            case roll
            case yaw
            case accelerationX
            case accelerationY
            case accelerationZ
            case magneticFieldX
            case magneticFieldY
            case magneticFieldZ
            case magneticFieldAccuracy
        }
        var timeInterval :          Double { return data[SampleDataType.timeInterval.rawValue] }
        var rotationX :             Double { return data[SampleDataType.rotationX.rawValue] }
        var rotationY :             Double { return data[SampleDataType.rotationY.rawValue] }
        var rotationZ :             Double { return data[SampleDataType.rotationZ.rawValue] }
        var gravityX :              Double { return data[SampleDataType.gravityX.rawValue] }
        var gravityY :              Double { return data[SampleDataType.gravityY.rawValue] }
        var gravityZ :              Double { return data[SampleDataType.gravityZ.rawValue] }
        var pitch :                 Double { return data[SampleDataType.pitch.rawValue] }
        var roll :                  Double { return data[SampleDataType.roll.rawValue] }
        var yaw :                   Double { return data[SampleDataType.yaw.rawValue] }
        var accelerationX :         Double { return data[SampleDataType.accelerationX.rawValue] }
        var accelerationY :         Double { return data[SampleDataType.accelerationY.rawValue] }
        var accelerationZ :     	Double { return data[SampleDataType.accelerationZ.rawValue] }
        var magneticFieldX :        Double { return data[SampleDataType.magneticFieldX.rawValue] }
        var magneticFieldY :        Double { return data[SampleDataType.magneticFieldY.rawValue] }
        var magneticFieldZ :        Double { return data[SampleDataType.magneticFieldZ.rawValue] }
        var magneticFieldAccuracy : Double { return data[SampleDataType.magneticFieldAccuracy.rawValue] }
        
        var data : [Double]
        
        init(data : [Double]) {
            self.data = data
        }
        
        func asAnyObject() -> AnyObject {
            return self as AnyObject
        }
    }
}
