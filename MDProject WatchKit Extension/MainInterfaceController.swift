//
//  MainInterfaceController.swift
//  MDProject WatchKit Extension
//
//  Created by Yevgeny Beygel on 1/13/18.
//  Copyright © 2018 BGU. All rights reserved.
//

import WatchKit

class MainInterfaceController: WKInterfaceController {
    
    enum ContextType : String {
        case play = "PLAY"
        case sample = "SAMPLE"
    }
    var contextForSegue : [String : ContextType] {
        return ["s_play" : ContextType.play,
                "s_sample" : ContextType.sample]
    }
    
    override func contextForSegue(withIdentifier segueIdentifier: String) -> Any? {
        return contextForSegue[segueIdentifier]
    }
}
