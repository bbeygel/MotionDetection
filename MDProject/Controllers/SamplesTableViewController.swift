//
//  SamplesTableViewController.swift
//  MDProject
//
//  Created by Yevgeny Beygel on 11/11/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit
import MessageUI

class SamplesTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    var arrSamples : [TennisMLSample] = [TennisMLSample]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(newDataArrived), name: NSNotification.Name.newDataArrived, object: nil)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @objc func newDataArrived(_ notification : NSNotification) {
        guard let newRawSamples = notification.object as? [[String : Any]] else { return }
        let newSamples = newRawSamples.map { TennisMLSample(features:$0["features"] as! [String],
                                                            values:$0["values"] as! [Any]) }
        arrSamples.append(contentsOf: newSamples)
        tableView.reloadData()
    }
    
    @IBAction func btnActionPressed() {
        self.createCSVMail()
    }
    
    private func createCSVData() -> String {
        guard arrSamples.count > 0,
            let features = arrSamples.first?.features else { return ""}
        let data = arrSamples.map{ return $0.values }
        
        var csvText = features.joined(separator: ",")
        csvText += " \n "
        for m in data {
            let newLine = m.map {
                return "\($0)"
                }.joined(separator: ",")
            csvText.append(newLine)
            csvText.append(" \n ")
        }
        return csvText
    }
    private func createCSVMail() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_yyyy_HH-mm"
        let convertedDate = dateFormatter.string(from: date)
        let fileName = convertedDate+"_Measurements.txt"
        let fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(fileName)
        
        let csvText = createCSVData()
        
        do {
            if MFMailComposeViewController.canSendMail() {
                try csvText.write(to: fpath!, atomically: true, encoding: String.Encoding.utf8)
                let emailController = MFMailComposeViewController()
                emailController.mailComposeDelegate = self
                emailController.setToRecipients(["anat.zaltz@gmail.com, hbeygel@gmail.com"])
                emailController.setSubject("MotionDetection Project - New measurements export")
                let partA = "Hi,\n\nThe .csv measurements export is attached\n\n Participant Name:"
                let partB = "Sent from the MD app"
                emailController.setMessageBody( partA + partB, isHTML: false)
                emailController.addAttachmentData(NSData(contentsOf: fpath!)! as Data, mimeType: "text/csv", fileName: fileName)
                present(emailController, animated: true, completion: nil)
            }
        }catch {
            print("Failed to fetch feed data, critical error: \(error)")
        }
    }
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrSamples.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sampleCell", for: indexPath)
        
        cell.textLabel?.text = "\(arrSamples[indexPath.row].values)"
        
        return cell
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
