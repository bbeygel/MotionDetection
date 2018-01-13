//
//  NotificationMessage.swift
//  MDProject
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static var message : NSNotification.Name { return NSNotification.Name("mein_message") }
    static var isSampling : NSNotification.Name { return NSNotification.Name("is_samling") }
    static var newDataArrived : NSNotification.Name { return NSNotification.Name("new_data_arrived") }
}
