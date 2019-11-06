//
//  ReportCell.swift
//  Public Eyes
//
//  Created by Fitsyu  on 24/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

class ReportCell: UITableViewCell {
    
    static let ID = "ReportCell"
    
    // MARK: Outlet
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    @IBOutlet weak var txWhat: UILabel!
    @IBOutlet weak var txWho: UILabel!
    @IBOutlet weak var txWhen: UILabel!
    @IBOutlet weak var txWhere: UILabel!
    
    @IBOutlet weak var txSubmitted: UILabel!
    
    @IBOutlet weak var miniMapImageView: UIImageView!
    
    var data: Report! {
        didSet {
            
            txWhat.text = data.what?.description
            txWho.text  = data.who
            
            txWhen.text = OurDateFormatter.string(from: data.when)
            
            if let location = data.whre {
            
                txWhere.text = "\(location.latitude), \(location.longitude)"
                
                 MapCache.shared.thumbnail(for: location, view: miniMapImageView)
            }
            
            let img = UIImage(contentsOfFile: data.how.photoUrl.path)
            thumbnailImageView.image = img
            
            txSubmitted.isHidden = !(data.submitted == .submitted)
            
            
       
        }
    }
}
