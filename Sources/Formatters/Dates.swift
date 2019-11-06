//
//  Dates.swift
//  Public Eyes
//
//  Created by Fitsyu  on 31/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import Foundation

let OurDateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "EEE, dd MMM yyyy hh:mm:ss"
    return df
}()
