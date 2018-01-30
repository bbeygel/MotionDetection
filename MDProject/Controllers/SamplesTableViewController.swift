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
                                                            values:$0["values"] as! [Any],
                                                            classification: $0["classification"] as! Int) }
        arrSamples.append(contentsOf: newSamples)
        tableView.reloadData()
    }
    
    @IBAction func btnActionPressed() {
        self.createCSVMail()
    }
    
    private func createCSVData() -> (x_train : String, x_test : String, y_train : String, y_test : String)? {
        guard arrSamples.count > 0,
            let features = arrSamples.first?.features else { return nil }
        let t_data = arrSamples.map{ return ($0.values,$0.classification) }
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
    
    private func createCSVMail() {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd_MM_yyyy_HH-mm"
        let convertedDate = dateFormatter.string(from: date)
        
        let x_train_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("x_train.csv")
        let x_test_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("x_test.csv")
        let y_train_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("y_train.csv")
        let y_test_fpath = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("y_test.csv")
        
        guard let mlData = createCSVData() else {
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
                emailController.setToRecipients(["anat.zaltz@gmail.com, hbeygel@gmail.com"])
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
    
    @IBAction func btnClosePressed() {
        guard arrSamples.isEmpty else {
            let alert = UIAlertController(title: "Warning", message: "controller isn't empty. if you leave all sampled data would be deleted, are you sure you want to exit?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .destructive, handler: { (action) in
                self.dismiss(animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil);
            return
        }
        self.dismiss(animated: true, completion: nil)
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
