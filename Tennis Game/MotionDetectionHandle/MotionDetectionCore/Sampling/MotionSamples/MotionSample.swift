//
//  MotionSample.swift
//  MotionDetection WatchKit Extension
//
//  Created by Yevgeny Beygel on 9/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation
import Common
import CoreML

protocol PMLMotion {
    var rawData : [MotionSample] { get set }
    var features : [String] { get }
    var values : [Any] { get }
    var classification : Int! { set get }
    init(features : [String], values: [Any], classification : Int, rawData: [MotionSample])
}

class TennisMLSample : PMLMotion, MLFeatureProvider {
    var featureNames: Set<String> {
        return Set(Feature.all)
    }
    
    func featureValue(for featureName: String) -> MLFeatureValue? {
        guard let feature = Feature(rawValue: featureName) else {
            return nil
        }
        return MLFeatureValue(double: value(for: feature))
    }
    
    
    var rawData: [MotionSample]
    
    var features: [String] {
        get {
            return Feature.all
        }
    }
    var values: [Any] {
        get {
            return [timestamp,
                    hand,
                    peakRate,
                    accumulatedYawRotation,
                    yawThreshold,
                    rateThreshold,
                    passedYawThreshold,
                    passedNegativeYawThreshold,
                    passedPeakRateThreshold,
                    passedNegativePeakRateThreshold]
        }
    }
    var classification : Int!
    
    enum Feature: String
    {
        case TIMESTAMP = "timestamp"
        case HAND = "hand"
        case PEAK_RATE = "peakRate"
        case ACCUM_YAW_ROT = "accumulatedYawRotation"
        case YAW_THRESH = "yawThreshold"
        case RATE_THRESH = "rateThreshold"
        case PASS_YAW_THRESH = "passedYawTreshold"
        case PASS_NEG_YAW_THRESH = "passedNegativeYawTreshold"
        case PASS_PEAK_THRESH = "passedPeakRateThreshold"
        case PASS_NEG_PEAK_THRESH = "passedNegativePeakRateThreshold"
        
        static var all : [String] {
            return [Feature.TIMESTAMP,
                    .HAND,
                    .PEAK_RATE,
                    .ACCUM_YAW_ROT,
                    .YAW_THRESH,
                    .RATE_THRESH,
                    .PASS_YAW_THRESH,
                    .PASS_NEG_YAW_THRESH,
                    .PASS_PEAK_THRESH,
                    .PASS_NEG_PEAK_THRESH].map { $0.rawValue  }
        }
    }

    var timestamp : Int!
    var hand : Int!
    var peakRate : Double!
    var accumulatedYawRotation : Double!
    var yawThreshold : Double!
    var rateThreshold : Double!
    var passedYawThreshold : Int!
    var passedNegativeYawThreshold : Int!
    var passedPeakRateThreshold : Int!
    var passedNegativePeakRateThreshold : Int!
    
    
    required init(features: [String], values: [Any], classification : Int, rawData: [MotionSample] = [MotionSample]()) {
        self.classification = classification
        self.rawData = rawData
        for feature in features {
            let featureIndex = features.index(of: feature)!
            let value = values[featureIndex]
            switch Feature(rawValue: feature) {
            case Feature.TIMESTAMP?: timestamp = value as! Int
            case Feature.HAND?: hand = value as! Int; break
            case Feature.PEAK_RATE?: peakRate = value as! Double; break
            case Feature.ACCUM_YAW_ROT?: accumulatedYawRotation = value as! Double; break
            case Feature.YAW_THRESH?: yawThreshold = value as! Double; break
            case Feature.RATE_THRESH?: rateThreshold = value as! Double; break
            case Feature.PASS_YAW_THRESH?: passedYawThreshold = value as! Int; break
            case Feature.PASS_NEG_YAW_THRESH?: passedNegativeYawThreshold = value as! Int; break
            case Feature.PASS_PEAK_THRESH?: passedPeakRateThreshold = value as! Int ; break
            case Feature.PASS_NEG_PEAK_THRESH?: passedNegativePeakRateThreshold = value as! Int; break
            default: break
            }
        }
    }
    
    init?(timestamp : Int, hand: Int, peakRate: Double, accumulatedYawRotation : Double, yawThreshold : Double, rateThreshold : Double, accelSum : Double = 0.0, rawData: [MotionSample] = [MotionSample]()) {
        self.timestamp = timestamp
        self.hand = hand; self.peakRate = peakRate;
        self.peakRate = peakRate
        self.accumulatedYawRotation = accumulatedYawRotation
        self.yawThreshold = yawThreshold
        self.rateThreshold = rateThreshold
        self.passedYawThreshold = accumulatedYawRotation > yawThreshold ? 1 : 0
        self.passedNegativeYawThreshold = accumulatedYawRotation < -yawThreshold ? 1 : 0
        self.passedPeakRateThreshold = peakRate > rateThreshold ? 1 : 0
        self.passedNegativePeakRateThreshold = peakRate < -rateThreshold ? 1 : 0
        
        if accelSum > 100 {
            if passedNegativeYawThreshold == 1, passedNegativePeakRateThreshold == 1 {
                // Counter clockwise swing.
                switch hand {
                case 0: classification = MotionType.backhand.rawValue; break
                case 1: classification = MotionType.forhand.rawValue; break
                default: return nil
                }
            } else if passedYawThreshold == 1, passedPeakRateThreshold == 1 {
                switch hand {
                case 0: classification = MotionType.forhand.rawValue; break
                case 1: classification = MotionType.backhand.rawValue; break
                default: return nil
                }
            } else {
                return nil
            }
        }
        self.rawData = rawData
    }
    
    func value(for feature: Feature) -> Double {
        switch feature {
            case .TIMESTAMP: return Double(timestamp)
            case .HAND: return Double(hand)
            case .PEAK_RATE: return peakRate
            case .ACCUM_YAW_ROT: return accumulatedYawRotation
            case .YAW_THRESH: return yawThreshold
            case .RATE_THRESH: return rateThreshold
            case .PASS_YAW_THRESH: return Double(passedYawThreshold)
            case .PASS_NEG_YAW_THRESH: return Double(passedNegativeYawThreshold)
            case .PASS_PEAK_THRESH: return Double(passedPeakRateThreshold)
            case .PASS_NEG_PEAK_THRESH: return Double(passedNegativePeakRateThreshold)
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
        case timestamp = 0
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
        
        
        static var all: [SampleDataType] {
            return [
            timestamp,
            rotationX,
            rotationY,
            rotationZ,
            gravityX,
            gravityY,
            gravityZ,
            pitch,
            roll,
            yaw,
            accelerationX,
            accelerationY,
            accelerationZ
            ]
        }
        static var labels: [String] {
            return all.map { String(describing: $0) }
        }
    }
    var timestamp :             Int = Int(Date().timeIntervalSince1970)
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
    
    let data : [Double]
    
    init(data : [Double]) {
        self.data = [Double(Date().timeIntervalSince1970)] + data
    }
    
    var asAnyObject : AnyObject {
        return self as AnyObject
    }
    func data(for type : SampleDataType) -> Double {
        return data[type.rawValue]
    }
}
