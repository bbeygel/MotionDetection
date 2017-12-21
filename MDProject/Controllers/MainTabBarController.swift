//
//  MainTabBarController.swift
//  MDProject
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    var samplesController : SamplesTableViewController {
        return self.viewControllers?.first as! SamplesTableViewController
    }
    var settingsController : SettingsTableViewController {
        return self.viewControllers?.last as! SettingsTableViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
