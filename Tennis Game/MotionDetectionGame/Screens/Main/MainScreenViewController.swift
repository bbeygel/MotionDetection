//
//  ViewController.swift
//  MotionDetectionGame
//
//  Created by Molda on 19/05/2018.
//  Copyright © 2018 Beygel. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class MainScreenViewController: UIViewController
{
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var mcAdvertiserAssistant: MCAdvertiserAssistant!
    
    @IBOutlet weak var lblTitle : UILabel!
    @IBOutlet weak var lblMessage : UILabel!
    @IBOutlet weak var imgRacket: UIImageView!
    
    init() {
        super.init(nibName: "MainScreen", bundle: Bundle.main)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        setup()
    }
    
    func setup() {
        peerID = MCPeerID(displayName: UIDevice.current.name)
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "game", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant.start()
    }
}

extension MainScreenViewController: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case MCSessionState.connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.notConnected:
            print("Not Connected: \(peerID.displayName)")
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        guard let message = String(data: data, encoding: .utf8) else {
            return
        }
        DispatchQueue.main.async { [unowned self] in
            var motionTypeString = "none"
            guard
                let motionTypeInt = Int(message) else {
                    return
            }
            switch motionTypeInt {
            case 0:
                self.imgRacket.image = #imageLiteral(resourceName: "ic_racket_red");
                motionTypeString = "Backhand"
                break
            case 1:
                self.imgRacket.image = #imageLiteral(resourceName: "ic_racket_green");
                motionTypeString = "Forehand"
                break
            default: return
            }
            
            self.lblMessage.text = "Performed Motion Type - \(motionTypeString)"
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        
    }
}
