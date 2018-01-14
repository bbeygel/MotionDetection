//
//  MotionSample.swift
//  MotionDetection WatchKit Extension
//
//  Created by Yevgeny Beygel on 9/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation
protocol PMLMotion : class {
    var features : [String] { get }
    var values : [Any] { get }
    var classification : Int! { set get }
    init(features : [String], values: [Any], classification : Int)
}

class TennisMLSample : PMLMotion {
    
    var features: [String] {
        get {
            return Feature.all
        }
    }
    var values: [Any] {
        get {
            return [timestamp, hand,peakRate,passedYawTreshold,passedNegativeYawTreshold,passedPeakRateThreshold,passedNegativePeakRateThreshold]
        }
    }
    var classification : Int!
    
    struct Feature {
        static let TIMESTAMP = "timestamp"
        static let HAND = "hand"
        static let PEAK_RATE = "peakRate"
        static let YAW_THRESH = "passedYawTreshold"
        static let NEG_YAW_THRESH = "passedNegativeYawTreshold"
        static let PEAK_THRESH = "passedPeakRateThreshold"
        static let NEG_PEAK_THRESH = "passedNegativePeakRateThreshold"
        static var all : [String] {
            return [TIMESTAMP,HAND,PEAK_RATE,YAW_THRESH,NEG_YAW_THRESH,PEAK_THRESH,NEG_PEAK_THRESH]
        }
    }
    
    var timestamp : Int!
    var hand : Int!
    var peakRate : Double!
    var passedYawTreshold : Int!
    var passedNegativeYawTreshold : Int!
    var passedPeakRateThreshold : Int!
    var passedNegativePeakRateThreshold : Int!
    
    
    required init(features: [String], values: [Any], classification : Int) {
        self.classification = classification
        for feature in features {
            let featureIndex = features.index(of: feature)!
            let value = values[featureIndex]
            switch feature {
            case Feature.TIMESTAMP: timestamp = value as! Int
            case Feature.HAND: hand = value as! Int; break
            case Feature.PEAK_RATE: peakRate = value as! Double; break
            case Feature.YAW_THRESH: passedYawTreshold = value as! Int; break
            case Feature.NEG_YAW_THRESH: passedNegativeYawTreshold = value as! Int; break
            case Feature.PEAK_THRESH: passedPeakRateThreshold = value as! Int ; break
            case Feature.NEG_PEAK_THRESH: passedNegativePeakRateThreshold = value as! Int; break
            default: break
            }
        }
    }
    
    init(timestamp : Int, hand: Int, peakRate: Double, passedYawTreshold: Bool, passedNegativeYawTreshold: Bool, passedPeakRateThreshold: Bool, passedNegativePeakRateThreshold: Bool) {
        self.timestamp = timestamp
        self.hand = hand; self.peakRate = peakRate;
        self.passedNegativeYawTreshold = passedNegativeYawTreshold ? 1 : 0
        self.passedPeakRateThreshold = passedPeakRateThreshold ? 1 : 0
        self.passedYawTreshold = passedYawTreshold ? 1 : 0
        self.passedNegativePeakRateThreshold = passedNegativePeakRateThreshold ? 1 : 0
        
        if passedNegativeYawTreshold, passedNegativePeakRateThreshold {
            // Counter clockwise swing.
            switch hand {
            case 0: classification = MotionType.backhand.rawValue; break
            case 1: classification = MotionType.forhand.rawValue; break
            default: classification = MotionType.none.rawValue; break
            }
        } else if passedYawTreshold, passedPeakRateThreshold {
            switch hand {
            case 0: classification = MotionType.forhand.rawValue; break
            case 1: classification = MotionType.backhand.rawValue; break
            default: classification = MotionType.none.rawValue; break
            }
        } else {
            classification = MotionType.none.rawValue
        }
    }
    
    var asRawObject : [String : Any] {
        return ["features" : features,
                "values" : values,
                "classification": classification]
    }
}

class MotionSample : NSObject {
    
    enum SampleDataType : Int {
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
    var accelerationZ :         Double { return data[SampleDataType.accelerationZ.rawValue] }
    var magneticFieldX :        Double { return data[SampleDataType.magneticFieldX.rawValue] }
    var magneticFieldY :        Double { return data[SampleDataType.magneticFieldY.rawValue] }
    var magneticFieldZ :        Double { return data[SampleDataType.magneticFieldZ.rawValue] }
    var magneticFieldAccuracy : Double { return data[SampleDataType.magneticFieldAccuracy.rawValue] }
    
    private var data : [Double]
    
    init(data : [Double]) {
        self.data = data
    }
    
    var asAnyObject : AnyObject {
        return self as AnyObject
    }
    func data(for type : SampleDataType) -> Double {
        return data[type.rawValue]
    }
}
