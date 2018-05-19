//
//  AppCommunicator.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 11/10/17.
//  Copyright © 2017 BGU. All rights reserved.
//

import Foundation
import WatchConnectivity

struct AppCommunicator {
    /// Sends data of any kind to phone app
    /// using the watch session object
    ///
    /// - Parameter data: stream to send to phone
    /// - Returns: did secceed sending data
    static func sendNotification(with data : AnyObject?, errorHandler : @escaping ((Error) -> Void)) {
        /// Checks if data and connection are valid
        guard let data = data,
            WCSession.isSupported() else {
                return
        }
        
        let message = [NSNotification.Name.message.rawValue : data,
                       NSNotification.Name.isSampling.rawValue : data.self is [AnyObject]] as [String : Any]
        
        WCSession.default.activate()
        DispatchQueue.main.async {
            WCSession.default.sendMessage(message, replyHandler: nil, errorHandler: {
                error in
                self.errorHandler(error: error as NSError, errorHandler)
            })
            
//            if WCSession.default.isReachable {
//                // sends messages with callbacks
//                // replyHandler should not be implemented!!!
//
//            } else {
//                WCSession.default.transferUserInfo(message)
//            }
        }
    }
    
    static func errorHandler(error: NSError, _ callback: ((Error)->Void)?) {
        print("Error Code: \(error.code)\n\(error.localizedDescription)")
    }
}
