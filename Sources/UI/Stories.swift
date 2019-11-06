//
//  VCx.swift
//  Public Eyes
//
//  Created by Fitsyu  on 26/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

enum Stories {
    
    case Hunt
    case ReportList
    
    func UI() -> UIViewController {
        
        switch self {
        case .Hunt:
            return VCxHunt()
            
        case .ReportList:
            return VCxReportList()
        }
    }
}
