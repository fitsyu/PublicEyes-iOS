//
//  VCxHunt.swift
//  Public Eyes
//
//  Created by Fitsyu  on 24/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

/// Story
///
/// # Getting started
///
/// Hunting is our term.
/// Technically it is to turn on the camera and have its feed ready
/// for us to capture the scene anytime we want to
///
/// The camera is automatically turned on and its feed is displayed
/// in preview rectangle at the center of the screen.
///
/// Press the `Start` button to start the video recording process.
///
/// By default, a feed will come from rear camera.
/// User can change that by pressing `Flip` button to
/// toggle which camera, front or rear, to be used.
///
/// To turn off the preview, a user can press `Preview`
/// button to toggle the visibility of camera feed.
///
/// Finally press the `Stop` button to stop recording
/// which should be visible in place where `Start` button
/// was pressed.
///
/// # Capturing
/// * The recording should already be started
///
/// Press the `Capture` button and it will take a video capture from
/// the active camera feed within 1 minute time frame. It starts from 30s
/// back from the moment to 30s forward. The resulting video capture is
/// then going to be associated with current timestamp and location
/// which should later can be seen in Reports page.
///
/// # Navigation
/// To see the captured reports, press the `Reports` button and
/// the user will be brought to Reports page to see his captures.
/// The camera should be stopped automatically if it was not stopped
/// prior to pressing this button
///

//let lat = center!.coordinate.latitude + faker.number.randomDouble(min: -0.01100010, max: 0.01100100)
//let lng = center!.coordinate.longitude + faker.number.randomDouble(min: -0.01100010, max: 0.01100100)

import UIKit
import AVFoundation
import CoreLocation
import UserNotifications
import MediaPlayer

final class VCxHunt: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var flipButton: UIButton!
    
    @IBOutlet weak var previewButton: UIButton!
    
    @IBOutlet weak var captureButton: UIButton!
    
    @IBOutlet weak var cameraFeedView: CameraFeedView!
    
    @IBOutlet weak var txMessage: UILabel!
    
    // MARK: Actions
    
    @IBAction func actOnCloseButton(_ sender: UIButton) {
        
        if hunting {
            assetWriter?.finishWriting {
                print("done writing to file")
                self.frameNumber = 0
            }
            
            
            Hunt.Act.Stop.dispatch()
        }
        
        dismiss(animated: true, completion: {  })
    }
    
    @IBAction func actOnStartButton(_ sender: UIButton) {
        
        if hunting == false {
            
            // setup writer
            let outputSettings: [String:Any] = [
                AVVideoWidthKey : Int(640),
                AVVideoHeightKey : Int(480),
                AVVideoCodecKey : AVVideoCodecType.h264
            ]
            
            assetWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video,
                                                  outputSettings: outputSettings)
            
            let attributes = [ kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32BGRA)]
            
            pixelBufferAdaptor =
                AVAssetWriterInputPixelBufferAdaptor(
                    assetWriterInput: assetWriterInput!,
                    sourcePixelBufferAttributes: attributes)
            
            
            
            let temp = FileManager.default.temporaryDirectory.appendingPathComponent("hunt-\(UUID().uuidString)").appendingPathExtension("mov")
            
            if FileManager.default.fileExists(atPath: temp.path) {
                print("removing old hunt.mov")
                try? FileManager.default.removeItem(at: temp)
            }
            
            self.videoUrl = temp
            
            
            assetWriter = try? AVAssetWriter(url: temp, fileType: .mov)
            assetWriter!.add(assetWriterInput!)
            assetWriterInput!.expectsMediaDataInRealTime = true
            assetWriterInput!.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 90 / 180))
            assetWriterInput!.preferredVolume = 0
            
            assetWriter!.startWriting()
            assetWriter!.startSession(atSourceTime: CMTime.zero)
            
            
            
            
            Hunt.Act.Start.dispatch()
        } else {
            
            assetWriter?.finishWriting {
                print("done writing to file")
                self.frameNumber = 0
            }
            
            
            Hunt.Act.Stop.dispatch()
        }
    }
    
    @IBAction func actOnFlipButton(_ sender: UIButton) {
     
        Hunt.Act.ToggleFlip.dispatch()
    }
    
    @IBAction func actOnPreviewButton(_ sender: UIButton) {
        
//        Hunt.Act.TogglePreviewing.dispatch()
    }
    
    @IBAction func actOnCaptureButton(_ sender: UIButton) {
     
//        self.images.removeAll()
//        collectionView.reloadData()
//
//        for sampleBuffer in sampleBuffers {
//
//            if let cvImage = CMSampleBufferGetImageBuffer(sampleBuffer) {
//                let ciImage = CIImage(cvImageBuffer: cvImage)
//                let uiImage = UIImage(ciImage: ciImage)
//                self.images.append(uiImage)
//            }
//            print("get:",self.images.count)
//            collectionView.reloadData()
//        }
        
        
        let settings = AVCapturePhotoSettings(format:
            [AVVideoCodecKey:AVVideoCodecType.jpeg]
        )
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // MARK: Life Cycles
    
    override func viewDidLoad() {
        
        locationManager.pausesLocationUpdatesAutomatically = true
        
        UNUserNotificationCenter.current().delegate = self
        
        MPRemoteCommandCenter.shared().togglePlayPauseCommand.addTarget { (event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus in
            
            // middle button (toggle/pause) is clicked
            print("event:", event.command)
            self.actOnCaptureButton(self.captureButton)
            
            return .success
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        Hunt.store.subscribe(self)
        
        Hunt.Act.TogglePreviewing.dispatch()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        
        Hunt.Act.Stop.dispatch()
        
        if isPermissionRequired() {
            
            print("requesting permissions..")
            
            // camera
            AVCaptureDevice.requestAccess(for: .video) { granted in
                
                if !granted {
                    
                    self.alert()
                    self.disableControls()
                }
            }
            
            // location
            locationManager.requestAlwaysAuthorization()
            
            // notification
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .providesAppNotificationSettings, .badge]) { (granted, error) in
                
                print("notification", granted)
            }
            
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        Hunt.Act.Stop.dispatch()
        Hunt.Act.TogglePreviewing.dispatch()
        
        cameraFeedView.videoPreviewLayer.session = nil
        captureSession?.stopRunning()
        captureSession = nil
        
        Hunt.store.unsubscribe(self)
    }
    
    // MARK: Properties
    
    var sounder: AVPlayer?
    
    var videoUrl: URL?
    var photoUrl: URL?

    var captureSession: AVCaptureSession?
    var videoOutput: AVCaptureVideoDataOutput?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPosition: AVCaptureDevice.Position = .back
    
    var hunting = false
  
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var assetWriterInput: AVAssetWriterInput?
    var assetWriter: AVAssetWriter?
    
    var frameNumber: Int64 = 0
    
    // MARK: Location Reading
    let locationManager = CLLocationManager()
}

// MARK: Helpers

extension VCxHunt {
    
    private func isPermissionRequired() -> Bool {
        
        var required1 = true
        
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            required1 = false
            
        case .notDetermined: // The user has not yet been asked for camera access.
            fallthrough
            
        case .denied: // The user has previously denied access.
            fallthrough
            
        case .restricted: // The user can't grant access due to restrictions.
            fallthrough
            
        default:
            print("unknown status:", AVCaptureDevice.authorizationStatus(for: .video))
            required1 = true
        }
        
        
        var required2 = true
        
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedAlways:
            required2 = false
            
        case .authorizedWhenInUse:
            required2 = false
            
        case .denied:
            fallthrough
            
        case .notDetermined:
            fallthrough
            
        case .restricted:
            fallthrough
            
        default:
            required2 = true
        }
        
        var required3 = true
        
        UNUserNotificationCenter.current().getNotificationSettings { settings in
        
            switch settings.authorizationStatus {
                
            case .authorized:
                
                required3 = false
                
            default:
                required3 = true
            }
        }
        
        return required1 || required2 || required3
    }
    
    private func setupCaptureSession() {
        
        
        captureSession = AVCaptureSession()
        
        captureSession?.beginConfiguration()
        
        // input
        guard
            let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                   for: .video, position: self.cameraPosition),
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession?.canAddInput(videoDeviceInput) ?? false
            else {
                print("no video device!")
                return
        }
        
        captureSession?.addInput(videoDeviceInput)
        
        // output
        
        videoOutput = AVCaptureVideoDataOutput()
        
        guard captureSession?.canAddOutput(videoOutput!) ?? false else { return }

        captureSession?.sessionPreset = .high
        captureSession?.addOutput(videoOutput!)

        videoOutput!.setSampleBufferDelegate(self, queue: .main)
        
        photoOutput = AVCapturePhotoOutput()
        captureSession?.addOutput(photoOutput!)
        
        
        captureSession?.commitConfiguration()
        
        cameraFeedView.videoPreviewLayer.masksToBounds = true
        cameraFeedView.videoPreviewLayer.videoGravity = .resizeAspectFill
        cameraFeedView.videoPreviewLayer.session = captureSession
    }
    
    private func alert() {
        
        print("not permitted to use camera")
        
        let alert = UIAlertController(title: "Alert",
                                      message: "not permitted to use camera", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    private func disableControls() {
        
        previewButton.isEnabled = false
        flipButton.isEnabled = false
        startButton.isEnabled = false
        captureButton.isEnabled = false
    }
    
    private func notify(with url: URL) {
        
        let content = UNMutableNotificationContent()
        content.title = "A Bad Scene just captured!"
        content.subtitle = "You are great. Get catch'em all!"
        content.body = "Tap to see"
        content.sound = UNNotificationSound(named: UNNotificationSoundName("cute-chirp1.mp3"))
        
        if let attachment = try? UNNotificationAttachment(identifier: UUID().uuidString,
                                                          url: url,
                                                          options: nil) {
            
            content.attachments.append(attachment)
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if let error = error  {
                
                print(error)
            }
        }
        
        

        
    }
    
    private func makeReport(imageUrl: URL) {
        
        let now = Date()
        
        // make a draft
        let report = Report(what: nil,
                            when: now,
                            whre: locationManager.location?.coordinate,
                            who: nil,
                            how: Proof(photoUrl: imageUrl,
                                       videoUrl: videoUrl!),
                            submitted: .notSubmitted,
                            id: UUID().uuidString)
        
        
        Hunt.Act.Create(report).dispatch()
    }
}


import ReSwift

extension VCxHunt: StoreSubscriber {
    
    func newState(state: Hunt.State) {
        
        infoLabel.text =
        """
        \(state.title.uppercased())
        hunting: \(state.isHunting)
        flipped: \(state.isFlipped)
        preview: \(state.isPreviewing)
        """
        
//        startButton.setTitle(state.isHunting ? "Stop" : "Start", for: .normal)
        
        startButton.setImage(UIImage(named: state.isHunting ? "icon_stop" : "icon_record" ), for: .normal)
        
        flipButton.setImage(UIImage(named: state.isFlipped ? "icon_camerafront" : "icon_cameraback" ), for: .normal)
        
        captureButton.isEnabled = state.isHunting

        hunting = state.isHunting
        
        if !hunting {
            txMessage.text = "Press to start hunting"
        } else {
            txMessage.text = "Press anywhere to capture"
        }
        
        // preview
        if state.isPreviewing {
            
            if let captureSession = captureSession, captureSession.isRunning {
                captureSession.stopRunning()
                cameraFeedView.videoPreviewLayer.session = nil
            }
            
            cameraPosition = state.isFlipped ? .front : .back
            
            setupCaptureSession()
            captureSession?.startRunning()
            cameraFeedView.videoPreviewLayer.isHidden = false
            
        } else {
            
            captureSession?.stopRunning()
            cameraFeedView.videoPreviewLayer.session = nil
            cameraFeedView.videoPreviewLayer.isHidden = true
        }
        
    }
}

extension VCxHunt: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
//        print("reading buffer")
        
        guard hunting else { return }
        
//        print("hunting")
        if assetWriterInput!.isReadyForMoreMediaData {
            
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
                pixelBufferAdaptor?.append(imageBuffer, withPresentationTime: CMTimeMake(value: frameNumber, timescale: 10))
            }
            
        }
        frameNumber += 1

    }
}

extension VCxHunt: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willBeginCaptureFor")
        
        captureButton.isEnabled = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("willCapturePhotoFor")
    }

    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("didCapturePhotoFor")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        print("didFinishProcessingPhoto")
        
        let tempUrl = FileManager.default.temporaryDirectory
        let photoUrl = tempUrl.appendingPathComponent("img_hunt-\(UUID().uuidString)").appendingPathExtension("jpeg")
        if let data = photo.fileDataRepresentation() {
        
            print("saving photo to", photoUrl.path)
            let OK = FileManager.default.createFile(atPath: photoUrl.path, contents: data, attributes: nil)
            self.photoUrl = photoUrl
            print("is saved", OK)
        }
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("didFinishCaptureFor")
        
        captureButton.isEnabled = true
        
        self.makeReport(imageUrl: self.photoUrl!)
        
        // notify(with: self.photoUrl!)
        
        // just to tease and easy you :)
        let soundUrl = Bundle.main.url(forResource: "cute-chirp1", withExtension: ".mp3")!
        sounder = AVPlayer(url: soundUrl)
        sounder?.play()
    }
}


extension VCxHunt: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}










//
//extension VCxHunt: AVCaptureFileOutputRecordingDelegate {
//
//    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
//        print("started recording to \(fileURL.absoluteString)")
//    }
//
//    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//
//        if let error = error {
//            print(error)
//        }
//        print("finished recording to \(outputFileURL.absoluteString)")
//    }
//}

//extension VCxHunt: UICollectionViewDataSource {
//
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return images.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.ID, for: indexPath) as! ImageCell
//
//        cell.imageView?.image =  images[indexPath.item]
//        cell.label?.text = "\(indexPath.item)"
//
//        return cell
//    }
//}
//
//class ImageCell: UICollectionViewCell {
//
//    static let ID = "ImageCell"
//
//    var imageView: UIImageView?
//    var label: UILabel?
//
//    override init(frame: CGRect) {
//
//        super.init(frame: frame)
//
//        self.imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
//        contentView.addSubview(imageView!)
//
//        self.label = UILabel(frame: CGRect(x: 0, y: 0, width: 60, height: 20))
//        self.label?.backgroundColor = UIColor.black
//        self.label?.textColor = UIColor.white
//        contentView.addSubview(label!)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}
