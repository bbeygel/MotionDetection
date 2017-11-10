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
    
    var motionSampler : MotionSampler?
    let session = WCSession.default
    
    func sendToPhone(_ message : NSObject?)
    {
        self.session.transferUserInfo
        self.session.sendMessage(["msg":message], replyHandler: nil, errorHandler: nil)
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
        guard let sampler = MotionSampler(startTime : Date(), delegate: self) else {
            return
        }
        motionSampler = sampler
        motionSampler!.startSampling()
        
        startButton.setEnabled(false)
        stopButton.setEnabled(true)
        self.lblAction.setText("Sampling...")
        //        self.lblTimer
    }
    
    @IBAction func stop() {
        startButton.setEnabled(true)
        stopButton.setEnabled(false)
        motionSampler?.stopSampling()
    }
    
    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {
        
    }
    
    // MARK: - Motion Sampler Delegates
    func motionSampler(_ sampler: MotionSampler, storeMotionSamples samples: [MotionSampler.Sample]) {
        /// Serialize the property access and UI updates on the main queue.
        _ = samples.map { return $0.description }
        self.sendToPhone(nil)
    }
    
    func motionSampler(_ sampler: MotionSampler, updateActionLabel label: String) {
        
    }
    func motionSampler(_ sampler: MotionSampler, updateTimerLabel label: String) {
        lblTimer.setText(label)
    }

}
