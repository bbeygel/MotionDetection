//
//  TestingViewController.swift
//  MDProject
//
//  Created by Yevgeny Beygel on 1/1/18.
//  Copyright © 2018 BGU. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {

    @IBOutlet weak var lblActionType: UILabel!
    @IBOutlet weak var imageClassification : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(newDataArrived), name: NSNotification.Name.newDataArrived, object: nil)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func newDataArrived(_ notification : NSNotification) {
        guard let newRawMotion = notification.object as? [String :AnyObject] else { return }
        let newSample = TennisMLSample(features:newRawMotion["features"] as! [String],
                                                values:newRawMotion["values"] as! [Any],
                                                classification:newRawMotion["classification"] as! Int)
        let motionType = MotionType(rawValue:newSample.classification)!
        guard motionType != .none else { return }
        
        switch motionType {
        case .backhand:
            lblActionType.text = "Backhand".uppercased()
            imageClassification.image = #imageLiteral(resourceName: "ic_racket_red")
            break
        case .forhand:
            lblActionType.text = "Forehand".uppercased()
            imageClassification.image = #imageLiteral(resourceName: "ic_racket_green")
            break
        case .none: break
        }
    }
    
    @IBAction func btnExitPressed() {
        self.dismiss(animated: true, completion: nil);
    }
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
