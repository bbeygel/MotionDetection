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
import MessageUI

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
    
    func didPerformMotion(_ motion: PMLMotion) {
        DispatchQueue.main.async {
            guard let motionType = MotionType(rawValue: motion.classification) else {
                print("Invalid Motion Tried To Be Handled By Tennis Handle")
                return
            }
            switch motionType {
            case .forhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_green")
                break
            case .backhand:
                self.imageView.image = #imageLiteral(resourceName: "ic_racket_red")
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

extension HandleScreenViewController: MFMailComposeViewControllerDelegate
{
    func sendSamples(_ samples : [TennisMLSample], to recipients: [String] = ["anat.zaltz@gmail.com, hbeygel@gmail.com"]) {
        let x_train_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("x_train.csv")
        let x_test_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("x_test.csv")
        let y_train_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("y_train.csv")
        let y_test_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("y_test.csv")
        
        guard let mlData = samples.asCSVFeaturedDataSet else {
            let alert = UIAlertController(title: "Error", message: "error creating data set", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        let dataToPath = [mlData.x_train : x_train_fpath,
                          mlData.x_test : x_test_fpath,
                          mlData.y_train : y_train_fpath,
                          mlData.y_test : y_test_fpath]
        do {
            if MFMailComposeViewController.canSendMail() {
                // writes csv to file
                for dataPath in dataToPath {
                    try dataPath.key.write(to: dataPath.value!, atomically: true, encoding: String.Encoding.utf8)
                }
                let emailController = MFMailComposeViewController()
                emailController.mailComposeDelegate = self
                emailController.setToRecipients(recipients)
                emailController.setSubject("MotionDetection Project - New measurements export")
                let partA = "Hi,\n\nThe .csv measurements export is attached\n\n Participant Name:"
                let partB = "Sent from the MD app"
                emailController.setMessageBody( partA + partB, isHTML: false)
                // adds csv file as attachment to file
                for path in [x_train_fpath,x_test_fpath,y_train_fpath,y_test_fpath] {
                    if let path = path,
                        let data = NSData(contentsOf: path) as Data? {
                        emailController.addAttachmentData(data, mimeType: "text/csv", fileName: path.lastPathComponent)
                    }
                }
                present(emailController, animated: true, completion: nil)
            }
        }catch {
            print("Failed to fetch feed data, critical error: \(error)")
        }

    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}


extension Collection where Element:TennisMLSample {
    var asCSVFeaturedDataSet : (x_train : String, x_test : String, y_train : String, y_test : String)? {
        // extracts the features
        guard self.count > 0,
            let features = self.first?.features else {
                return nil
        }
        
        // Creating Dataset with extracted features
        let t_data = self.map{ return ($0.values,$0.classification) }
        let signalsData = t_data.map {
            return $0.0.map{
                value in
                return "\(value)"
                }.joined(separator: ",")
        }
        let features_line = features.joined(separator: ",") + "\n"
        let x_train = features_line + signalsData[0..<t_data.count*2/3].joined(separator: "\n")
        let x_test = features_line + signalsData[t_data.count*2/3..<t_data.count].joined(separator: "\n")
        let y_train = t_data[0..<t_data.count*2/3].map { return "\($0.1!) "}.joined(separator: "\n")
        let y_test = t_data[t_data.count*2/3..<t_data.count].map { return "\($0.1!) "}.joined(separator: "\n")
        
        return (x_train,x_test,y_train,y_test)
    }
}


/*
 @objc func newDataArrived(_ notification : NSNotification) {
 guard let newRawSamples = notification.object as? [[String : Any]] else { return }
 
 arrSamples.append(contentsOf: newSamples)
 tableView.reloadData()
 }
 
 @IBAction func btnActionPressed() {
 self.createCSVMail()
 }
 
 
 
 private func createCSVMail() {
 let date = Date()
 }
 */



