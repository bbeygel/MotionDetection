//
//  NavigationProtocol.swift
//  MDProject
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation

protocol INavigation : NSObjectProtocol {
    func navigate(to route : Screens.Destination)
}

struct Screens {
    typealias Destination = String
    
    static let mainTabController    = "app_tab"
    static let settingsController   = "app_tab/tab_settings"
}
