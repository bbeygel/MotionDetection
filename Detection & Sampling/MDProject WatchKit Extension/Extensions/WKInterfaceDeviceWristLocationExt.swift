//
//  WKInterfaceDeviceWristLocationExt.swift
//  MDProject WatchKit Extension
//
//  Created by Molda on 10/04/2018.
//  Copyright © 2018 BGU. All rights reserved.
//

import Foundation
import WatchKit

extension WKInterfaceDeviceWristLocation {
    var opposite: WKInterfaceDeviceWristLocation {
        switch self {
        case .left: return .right
        case .right: return .left
        }
    }
}
