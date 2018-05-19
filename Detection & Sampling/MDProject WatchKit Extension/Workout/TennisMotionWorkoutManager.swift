//
//  TennisMotionWorkoutManager.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import HealthKit

class TennisMotionWorkoutManager : PMotionWorkoutManager {
    
    static let shared = TennisMotionWorkoutManager()
    
    var delegate: WorkoutManagerDelegate?
    let healthStore = HKHealthStore()
    var session : HKWorkoutSession?
    var sampler: PMotionSampler = TennisMotionSampler()
    var isSampling : Bool! {
        didSet {
            (sampler as? TennisMotionSampler)?.isSampling = isSampling
        }
    }
    
    var sampledMotions = [TennisMLSample]()
    
    var forhandCount : Int {
        return sampledMotions.filter{
            (sample: TennisMLSample) -> Bool in
            return sample.classification == MotionType.forhand.rawValue
            }.count
    }
    var backhandCount : Int {
        return sampledMotions.filter{
            (sample: TennisMLSample) -> Bool in
            return sample.classification == MotionType.backhand.rawValue
            }.count
    }
    private init() {
        sampler.delegate = self
    }
    
    func startWorkout() {
        sampler.startSampling()
    }
    
    func stopWorkout() {
        sampler.stopSampling()
        AppCommunicator.sendNotification(with: sampledMotions.map { return $0.asRawObject } as AnyObject) {
            error in
            print(error.localizedDescription)
        }
    }
}


// MARK: - MotionSampler delegate functions
extension TennisMotionWorkoutManager {
    func motionSampler(_ sampler: PMotionSampler, didSampleMotion motion: PMLMotion) {
        guard let currTennisMotion = motion as? TennisMLSample else { return }
        
        if let lastTennisMotion = sampledMotions.last,
            lastTennisMotion.classification != MotionType.none.rawValue,
            currTennisMotion.classification != MotionType.none.rawValue,
            lastTennisMotion.classification != currTennisMotion.classification,
            currTennisMotion.timestamp == lastTennisMotion.timestamp {
            currTennisMotion.classification = MotionType.none.rawValue
        }
        
        sampledMotions.append(currTennisMotion)
        self.delegate?.didPerformMotion(MotionType(rawValue:currTennisMotion.classification)!)
        if !isSampling,
            currTennisMotion.classification != MotionType.none.rawValue {
            AppCommunicator.sendNotification(with: currTennisMotion.asRawObject as AnyObject) {
                error in
                print(error.localizedDescription)
            }
        }
    }
}
