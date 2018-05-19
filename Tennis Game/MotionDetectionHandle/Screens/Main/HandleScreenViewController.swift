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

    
    internal let communications: GameSessionManager
    private let tennisWM:   TennisMotionWorkoutManager
    
    init() {
        communications = GameSessionManager()
        tennisWM = TennisMotionWorkoutManager()

        super.init(nibName: "HandleScreen", bundle: Bundle.main)
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
        
        switch tennisWM.isSampling {
        case true:
            sender.backgroundColor = UIColor.green
            sender.setTitle("Start Detection", for: UIControlState())
            tennisWM.stopWorkout()
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
    
    func didPerformMotion(_ motionType: MotionType) {
        DispatchQueue.main.async {
            switch motionType {
            case .forhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_green")
                break
            case .backhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_red")
                break
            default:
                break
            }
            
            let message = "Performed Motion Type - \(motionType)"
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
}
