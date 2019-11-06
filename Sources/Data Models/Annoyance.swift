//
//  Annoyance.swift
//  Public Eyes
//
//  Created by Fitsyu  on 06/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

enum Annoyance {
    
    case littering
    case smoking
    case illegalParking
    case other(String)
}

extension Annoyance: Equatable {}

extension Annoyance: CustomStringConvertible {
    
    var description: String {
        switch self {
            
        case .littering:
            return "Buang sampah"
            
        case .smoking:
            return "Merokok"
            
        case .illegalParking:
            return "Parkir ilegal"
            
        case .other(let doing):
            return doing
        }
    }
}
