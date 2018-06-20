//
//  PMotionWorkoutManager.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import HealthKit

protocol WorkoutManagerDelegate : class {
    func didPerformMotion(_ motionType : MotionType)
}
protocol PMotionWorkoutManager : MotionSamplerDelegate {
    
    var healthStore : HKHealthStore { get }
    var session : HKWorkoutSession? { get }
    var sampler : PMotionSampler { get }
    var delegate: WorkoutManagerDelegate? { get set }
    
    func startWorkout();
    func stopWorkout();
}

