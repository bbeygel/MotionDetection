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
    
    let model : rf_tennis
    
    private init() {
        model = rf_tennis.init()
    }
    
    func classifyMotion(_ motion: TennisMLSample) {
        do {
            let data = try MLMultiArray(shape: [10], dataType: .double)
            // FIX: need to implement passing real data
            let pred = try model
                .prediction(Signals: data)
                .classProbability.reduce(into: (key: Int64(0), value: Double(0)), { (res, prob) in
                    if prob.value > res.value {
                        res.key = prob.key
                        res.value = prob.value
                    }
                })
            print("Prediction Is = \(pred)")
        } catch {
            print("Error While Classifying - \(error)")
        }
    }
}
