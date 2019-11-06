//
//  ViewController.swift
//  Public Eyes
//
//  Created by Fitsyu  on 05/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit
import MediaPlayer

class ExperimentViewController: UIViewController {
    
    var imageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("vdl")
        
        // UIApplication.shared.beginReceivingRemoteControlEvents()
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { (event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            
            // middle button (toggle/pause) is clicked
            print("event:", event.command)
            self.shot()
            
            return .success
        }
        
        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 300))
        view.addSubview(imageView!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("vda")
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            self.setupCaptureSession()
            
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.setupCaptureSession()
                }
            }
            
        case .denied: // The user has previously denied access.
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            return
                
        default:
            print("unknown status:", AVCaptureDevice.authorizationStatus(for: .video))
            return
        }
    }
    
    let captureSession = AVCaptureSession()
    let photoOutput = AVCapturePhotoOutput()
    
    let videoOutput = AVCaptureVideoDataOutput()
    
    func setupCaptureSession() {
        
        captureSession.beginConfiguration()
        
        // input
        let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                  for: .video, position: .back)
        
        guard let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice!),
            captureSession.canAddInput(videoDeviceInput)
            else { return }
        
        captureSession.addInput(videoDeviceInput)
        
        // output
        
        
        guard captureSession.canAddOutput(photoOutput) else { return }
        captureSession.sessionPreset = .photo
        captureSession.addOutput(photoOutput)
        
        
        captureSession.commitConfiguration()
    }
    
    lazy var settings: AVCapturePhotoSettings = {
        let _settings = AVCapturePhotoSettings()
        _settings.flashMode = .on
        return _settings
    }()
    
    func shot() {
        
        captureSession.startRunning()
        
        photoOutput.capturePhoto(with: settings, delegate: self)        
    }
}

extension ExperimentViewController: AVCapturePhotoCaptureDelegate {

    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("taken a photo")
        
//        let metadata = photo.metadata
//        let timestamp = photo.timestamp
        if let imageData = photo.fileDataRepresentation(), let image = UIImage(data: imageData) {
            print("setting the image")
            self.imageView?.image = image
        }
        
//        print(metadata, timestamp)
        
        captureSession.stopRunning()
    }
}
