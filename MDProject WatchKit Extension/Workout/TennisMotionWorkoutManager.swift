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
    
    var sampledMotions = [Date : MotionType]()
    var forhandCount : Int {
        return sampledMotions.filter{
            (key : Date, value: MotionType) -> Bool in
            return value == .forhand
            }.count
    }
    var backhandCount : Int {
        return sampledMotions.filter{
            (key,value) -> Bool in
            return value == .backhand
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
    }
}


// MARK: - MotionSampler delegate functions
extension TennisMotionWorkoutManager {
    func motionSampler(_ sampler: PMotionSampler, didSampleMotion motionType: MotionType, forTime timestamp: Date) {
        self.sampledMotions[timestamp] = motionType
        self.delegate?.didPerformMotion(motionType)
        AppCommunicator.sendNotification(with: motionType.rawValue) {
            error in
            print(error.localizedDescription)
        }
    }
}
