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
        guard let lastTennisMotion = motion as? TennisMLSample else { return }
        sampledMotions.append(lastTennisMotion)
        self.delegate?.didPerformMotion(MotionType(rawValue:lastTennisMotion.classification)!)
        if !isSampling {
            AppCommunicator.sendNotification(with: lastTennisMotion.asRawObject as AnyObject) {
                error in
                print(error.localizedDescription)
            }
        }
    }
}
