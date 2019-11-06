//
//  Report.swift
//  Public Eyes
//
//  Created by Fitsyu  on 06/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//


import Foundation
import CoreLocation

struct Report {
    
    var what: Annoyance?
    var when: Foundation.Date
    var whre: CLLocationCoordinate2D?
    var who: String?
    var how: Proof
    
    var submitted: SubmissionStatus
    var id: String = ""
}


extension Report: Equatable {
    
    static func == (lhs: Report, rhs: Report) -> Bool {
        
        return lhs.what == rhs.what && lhs.when == rhs.when && lhs.who == rhs.who
    }
}

import Fakery
extension Report {
    
    static func fakes() -> [Report] {
        
        print("once")
        
//        let img1 = "https://imgx.gridoto.com/crop/0x0:0x0/700x465/photo/2019/07/04/2155296500.jpg"
//
//        let img2 = "https://imgx.gridoto.com/crop/0x0:0x0/700x465/photo/2019/06/11/4083762007.jpg"
//
//        let img3 = "https://akcdn.detik.net.id/community/media/visual/2016/03/14/63f9f5c7-52c2-46f2-adca-459a16310af0.jpg?w=780&q=90"
//
        
        let faker = Faker()
        
        
        
        let location = Location(latitude: -6.293926, longitude: 106.7298503 ) // Ragunan
        
        let annoyances: [ Annoyance ] = [ .illegalParking, .littering, .smoking, .other("berisik") ]
        
        
        var reports: [Report] = (1...2).map { _ in
            
            let submitted = faker.number.randomBool()
            let what = submitted ? annoyances[faker.number.randomInt(min: 0, max: 3)] : .other("")
            let who  = submitted ? "B \(faker.number.randomInt(min: 1000, max: 9999)) XX" : ""

            
//            
//            var cover = ""
//            switch what {
//            
//            case .littering:
//                cover = img1
//            case .smoking:
//                cover = img2
//            case .illegalParking:
//                cover = img3
//                
//            default:
//                cover = img1
//                
//            }
            
            
            
            let proof = Proof(photoUrl: Bundle.main.url(forResource: "img12", withExtension: ".jpg")!,
                              videoUrl: Bundle.main.url(forResource: "trim", withExtension: ".mp4")!)
            
            return Report(what: what,
                   when: faker.date.backward(days: 5),
                   whre: location,
                   who: who,
                   how: proof,
                   submitted: .notSubmitted,
                   id: UUID().uuidString)
        }
        
        if var report = reports.last {
            report.how.photoUrl = Bundle.main.url(forResource: "crz-1", withExtension: ".jpg")!
            report.how.videoUrl = Bundle.main.url(forResource: "trim2", withExtension: ".mp4")!
            
            reports.removeLast()
            reports.append(report)
        }
        
        return reports
    }
}
