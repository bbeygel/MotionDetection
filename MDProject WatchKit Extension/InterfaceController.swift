//
//  InterfaceController.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import WatchKit
import Foundation


class MainInterfaceController: WKInterfaceController {

    var active = false
    @IBOutlet var lblTimer : WKInterfaceLabel!
    @IBOutlet weak var lblAction : WKInterfaceLabel!
    
    @IBOutlet  var startButton: WKInterfaceButton!
    @IBOutlet  var stopButton: WKInterfaceButton!
    
    var reps = 0
    
    var motionSampler : MotionSampler {
        return MotionSampler.shared
    }
    
    // MARK: WKInterfaceController
    override func willActivate() {
        super.willActivate()
        active = true
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }
    
    // MARK: Interface Bindings
    @IBAction func start() {
        motionSampler.startSampling()
        
        startButton.setEnabled(false)
        stopButton.setEnabled(true)
        self.lblAction.setText("Sampling...")
        //        self.lblTimer
    }
    
    @IBAction func stop() {
        startButton.setEnabled(true)
        stopButton.setEnabled(false)
        motionSampler.stopSampling()
    }
    
    // MARK: - Motion Sampler Delegates
    func motionSampler(_ sampler: MotionSampler, storeMotionSamples samples: [MotionSampler.Sample]) {
        /// Serialize the property access and UI updates on the main queue.
        AppCommunicator.sendNotification(with: samples as AnyObject) {
            error in
            print(error)
        }
    }
    
    func motionSampler(_ sampler: MotionSampler, updateActionLabel label: String) {
        
    }
    func motionSampler(_ sampler: MotionSampler, updateTimerLabel label: String) {
        lblTimer.setText(label)
    }

}
