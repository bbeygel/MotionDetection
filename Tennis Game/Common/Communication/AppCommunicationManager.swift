//
//  AppCommunicationManager.swift
//  MotionDetectionHandle
//
//  Created by Molda on 19/05/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import Foundation
import MultipeerConnectivity

public final class GameSessionManager {
    
    private let peerID: MCPeerID
    private let mcSession: MCSession
    
    public init() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
    }
    
    public func sendMessage(data: Data?, callback: (Bool,String?)->()) {
        var success = false
        var errorMessage : String? = nil
        defer {
            callback(success,errorMessage)
        }
    
        guard mcSession.connectedPeers.count > 0 else {
            errorMessage = "Not Connected To Any Peer"
            return
        }
        
        guard let data = data else {
            errorMessage = "Data Is Invalid"
            return
        }
        
        do {
            try mcSession.send(data,
                               toPeers: mcSession.connectedPeers,
                               with: .reliable)
            success = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    public func openJoinSession(from vc: MCBrowserViewControllerDelegate) {
        let mcBrowser = MCBrowserViewController(serviceType: "game", session: mcSession)
        mcBrowser.delegate = vc
        (vc as? UIViewController)?.present(mcBrowser, animated: true)
    }
}
