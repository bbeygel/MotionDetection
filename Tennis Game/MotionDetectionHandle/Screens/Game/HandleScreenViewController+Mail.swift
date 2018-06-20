//
//  HandleScreenViewController+Mail.swift
//  MotionDetectionHandle
//
//  Created by Molda on 20/06/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import Foundation
import Common
import MessageUI

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
