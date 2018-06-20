//
//  TennisMotionClassifier.swift
//  MotionDetectionHandle
//
//  Created by Molda on 30/05/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import Foundation
import CoreML

final class TennisMotionClassifier
{
    static let shared = TennisMotionClassifier()
    
    private let rfModel = MLRandomForest()
    private let rnnModel = keras_lstm_tennis()
    
    private init() {}
    
    func classify(_ motion: TennisMLSample) -> Int {
        do {
            let input = MLRandomForestInput(
                accumulatedYawRotation: "\(motion.accumulatedYawRotation)",
                hand: "\(motion.hand)",
                timestamp: "\(motion.timestamp)",
                peakRate: "\(motion.peakRate)"
            )
            
            let pred = try rfModel
                .prediction(input: input)
                .MotionType
            return Int(pred)
        } catch {
            print("Error While Classifying - \(error)")
        }
        return -1
    }
}
