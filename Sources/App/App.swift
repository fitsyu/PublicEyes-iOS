//
//  App.swift
//  Public Eyes
//
//  Created by Fitsyu  on 05/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

class App: UIApplication {
    
    
    override func sendEvent(_ event: UIEvent) {
        
        if event.type == UIEvent.EventType.remoteControl {
            
            print("receive a remove event", event)
            dump(event)
            
        } else {
            
            super.sendEvent(event)
        }
        
    }
}



