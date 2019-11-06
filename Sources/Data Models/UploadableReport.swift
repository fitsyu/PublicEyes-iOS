//
//  UploadableReport.swift
//  Public Eyes
//
//  Created by Fitsyu  on 31/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import Foundation

struct UploadableReport: Codable {
 
    var what: String
    var when: String
    var whre: UploadbleLocation
    var who: String
    var how: UploadableProof
}

struct UploadbleLocation: Codable {
    var latitude: Double
    var longitude: Double
}

struct UploadableProof: Codable {
    var photo: Data
    var videoData: Data?
}


extension UploadableReport {
    
    init(from report: Report) {
        
        
        
        self.what = report.what!.description
        self.when = report.when.description
        self.whre = UploadbleLocation(latitude: report.whre!.latitude,
                                 longitude: report.whre!.longitude)
        self.who = report.who!
        
        
        let imageData = try! Data(contentsOf: report.how.photoUrl)
        let videoData = try! Data(contentsOf: report.how.videoUrl!)

        how = UploadableProof(photo: imageData,
                              videoData: videoData)
    }
    
}
