//
//  Types.swift
//  MotionDetectionHandle
//
//  Created by Molda on 19/05/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import Foundation

public enum MotionType: Int {
    case backhand = 0
    case forhand
}

public enum HandSide: Int {
    case left
    case right
    
    var opposite: HandSide {
        switch self {
        case .left:
            return .right
        case .right:
            return .left
        }
    }
}
