//
//  CameraFeedView.swift
//  Public Eyes
//
//  Created by Fitsyu  on 27/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit
import AVFoundation

class CameraFeedView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
