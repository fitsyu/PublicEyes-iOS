//
//  SubmissionStatus.swift
//  Public Eyes
//
//  Created by Fitsyu  on 31/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//


enum SubmissionStatus: CustomStringConvertible {
    
    case notSubmitted
    case submitting
    case submitted
    
    var description: String {
        switch self {
        case .notSubmitted:
            return "Submit"
        case .submitting:
            return "Submitting.."
        case .submitted:
            return "Submitted"
        }
    }
}
