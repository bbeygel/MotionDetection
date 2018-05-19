//
//  TennisMotionSample.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/20/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit

class TennisMotionSample: MotionSample {
    
    var rateAlongGravity : Double!
    
    override init(data: [Double]) {
        super.init(data: data)
        rateAlongGravity =  rotationX * gravityX +
                            rotationY * gravityY +
                            rotationZ * gravityZ;
    }
}
