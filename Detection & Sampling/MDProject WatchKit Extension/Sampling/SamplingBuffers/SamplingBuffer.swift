//
//  SamplingBuffer.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 1/24/18.
//  Copyright © 2018 BGU. All rights reserved.
//

import UIKit

class SamplingBuffer: PSamplingBuffer {
    
    var buffer: [Double] { return [Double]() }
    
    internal var data: [MotionSample] = [MotionSample]() {
        didSet {
            if data.count > size {
                data.removeLast()
            }
        }
    }
    
    var size: Int
    
    // MARK: Initialization
    required init(size: Int) {
        
        self.size = size
    }
    
    // MARK: Running Buffer
    func addSample(_ sample: MotionSample) {
        data.insert(sample, at:0)
        if data.count > size  {
            data.removeLast()
        }
    }
    func removeLastSample() {
        data.removeLast()
    }
    func reset() {
        data.removeAll()
    }
    
    var isFull : Bool {
        return size == data.count
    }
    
    var sum : Double {
        return buffer.reduce(0.0, +)
    }
    
    var min : Double {
        var min = Double.leastNormalMagnitude
        if let minBuffer = buffer.min() {
            min = minBuffer
        }
        return min
    }
    
    var max : Double {
        var max = Double.greatestFiniteMagnitude
        if let maxBuffer = buffer.max() {
            max = maxBuffer
        }
        return max
    }
    
    var recentMean : Double {
        // Calculate the mean over the beginning half of the buffer.
        let recentCount = self.size / 2
        var mean = 0.0
        
        if (buffer.count >= recentCount) {
            let recentBuffer = buffer[0..<recentCount]
            mean = recentBuffer.reduce(0.0, +) / Double(recentBuffer.count)
        }
        return mean
    }
}
