//
//  PMotionWorkoutManager.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import Common

protocol WorkoutManagerDelegate : class {
    func didPerformMotion(_ motion : PMLMotion)
    func didFinishSamplingMotions(_ motions: [PMLMotion])
}

extension WorkoutManagerDelegate {
    func didFinishSamplingMotions(_ motions: [PMLMotion]){}
}

protocol PMotionWorkoutManager : MotionSamplerDelegate {
    
    var sampler : PMotionSampler { get }
    var delegate: WorkoutManagerDelegate? { get set }
    
    func startWorkout();
    func stopWorkout();
}

