//
//  PunchLog.swift
//  Punch
//
//  Created by Stephen Wong on 1/6/16.
//  Copyright © 2016 Intrepid Pursuits. All rights reserved.
//

import Foundation

class PunchLog {
    private var gotToWork: Bool
    
    init() {
        gotToWork = false
    }
    
    internal func punchInToWork() {
        gotToWork = true
    }
    
    internal func beenToWork() -> Bool {
        return gotToWork
    }
}
