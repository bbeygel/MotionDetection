//
//  InterfaceController.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import WatchKit
import Foundation


class TennisInterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    
    // MARK: Properties
    
    let workoutManager = TennisMotionWorkoutManager.shared
    var active = false
    var forehandCount = 0
    var backhandCount = 0
    var context : MainInterfaceController.ContextType!
    
    // MARK: Interface Properties
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var backhandCountLabel: WKInterfaceLabel!
    @IBOutlet weak var forehandCountLabel: WKInterfaceLabel!
    
    // MARK: Initialization
    
    override init() {
        super.init()
        workoutManager.delegate = self
    }
    
    // MARK: WKInterfaceController
    override func awake(withContext context: Any?) {
        self.context = context as? MainInterfaceController.ContextType
        workoutManager.isSampling = self.context == .sample
    }
    
    override func willActivate() {
        super.willActivate()
        active = true
        // On re-activation, update with the cached values.
        updateLabels()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }
    
    // MARK: Interface Bindings
    
    @IBAction func start() {
        titleLabel.setText("Workout started")
        workoutManager.startWorkout()
    }
    
    @IBAction func stop() {
        titleLabel.setText("Workout stopped")
        workoutManager.stopWorkout()
    }
    
    // MARK: WorkoutManagerDelegate    
    func didPerformMotion(_ motionType: MotionType) {
        switch motionType {
        case .backhand:
            self.backhandCount += 1; break
        case .forhand:
            self.forehandCount += 1; break
        case .none:
            break
        }
        self.updateLabels()
    }
    
    // MARK: Convenience
    
    func updateLabels() {
        if active {
            forehandCountLabel.setText("\(forehandCount)")
            backhandCountLabel.setText("\(backhandCount)")
        }
    }
}
