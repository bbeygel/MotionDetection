//
//  SamplingBuffer.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 12/16/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import UIKit


/// Mark: - Samples Data Holder
protocol PSamplingBuffer: class {
    var buffer : [Double] { get }
    var data : [MotionSample] { get set }
    var size : Int { get set }
    
    init(size: Int)
    func addSample(_ sample: MotionSample)
    func reset()
    var isFull : Bool { get }
    
    var sum : Double { get }
    var min : Double { get }
    var max : Double { get }
    var recentMean : Double { get }
}
