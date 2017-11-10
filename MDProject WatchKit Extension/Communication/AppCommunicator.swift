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
        guard let message = data as? Any,
            WCSession.default.isReachable else {
                print ("data wasn't send due to lack of data of lack of connection...obviously")
                return
        }
        // sends messages with callbacks
        WCSession.default.sendMessage([NotificationMessage.message : message], replyHandler: {
            message in
            print ("Received Message To Watch : \(message)")
        }, errorHandler: errorHandler)
    }
}
