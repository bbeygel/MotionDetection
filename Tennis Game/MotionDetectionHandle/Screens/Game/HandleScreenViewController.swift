//
//  ViewController.swift
//  MotionDetectionHandle
//
//  Created by Molda on 19/05/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import UIKit
import MultipeerConnectivity
import Common

class HandleScreenViewController: UIViewController {

    @IBOutlet weak var btnJoin : UIButton!
    @IBOutlet weak var btnStart : UIButton!
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var segUsedHand: UISegmentedControl!
    
    internal let communications: GameSessionManager
    private let tennisWM:   TennisMotionWorkoutManager
    
    init() {
        communications = GameSessionManager()
        tennisWM = TennisMotionWorkoutManager()

        super.init(nibName: "HandleScreen", bundle: Bundle.main)
    }
    
    
    @IBAction func didChangeHand(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: tennisWM.setHandSide(.left) ;break
        case 1: tennisWM.setHandSide(.right) ;break
        default: break
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        communications = GameSessionManager()
        tennisWM = TennisMotionWorkoutManager()
        super.init(coder: aDecoder)
    }
    
    @IBAction func joinSession(_ sender: UIButton) {
        communications.openJoinSession(from: self)
    }
    
    @IBAction func startDetection(_ sender: UIButton) {
        switch tennisWM.isRunning {
        case true:
            sender.backgroundColor = UIColor.init(red: 0.0, green: 144.0/255.0, blue: 81.0/255.0, alpha: 1)
            sender.setTitle("Start Detection", for: UIControlState())
            tennisWM.stopWorkout()
            communications.sendMessage(data: "stop".data(using: .utf8), callback: { _,_  in })
            break
        case false:
            sender.backgroundColor = UIColor.red
            sender.setTitle("Stop Detection", for: UIControlState())
            tennisWM.startWorkout()
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tennisWM.delegate = self
    }
}


extension HandleScreenViewController: MCBrowserViewControllerDelegate {
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
        self.btnJoin.isEnabled = false
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true, completion: nil)
    }
}

extension HandleScreenViewController: WorkoutManagerDelegate {
    
    func didPerformMotion(_ motion: PMLMotion, with classification: MotionType) {
        guard let tennisMotion = motion as? TennisMLSample else {
            print("Invalid Motion Tried To Be Handled By Tennis Handle")
            return
        }
        DispatchQueue.main.async {
            guard let motionType = tennisMotion.classification else { return }
            switch motionType {
            case .forhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_green")
                break
            case .backhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_red")
                break
            default: break
            }
            
            let message = "\(motionType.rawValue)"
            let messageData = message.data(using: .utf8)
            
            self.communications.sendMessage(data: messageData) {
                (success, error) in
                if !success {
                    let ac = UIAlertController(title: "Send error", message: error, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    func didFinishSamplingMotions(_ motions: [PMLMotion]) {
        guard let tennisSamples = motions as? [TennisMLSample] else {
            print("Invalid Motions Tried To Be Handled By Tennis Handle")
            return
        }
        
        let controller = UIAlertController(title: "Finished Sampling", message: "The App has finished sampling your motions, would you like to get the dataset to the mail?", preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "Send", style: .default, handler: {[tennisSamples] _ in
            self.sendSamples(tennisSamples)
        }))
        controller.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(controller, animated: true, completion: nil)
    }
}

