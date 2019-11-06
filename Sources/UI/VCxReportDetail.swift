//
//  ShotViewController.swift
//  Public Eyes
//
//  Created by Fitsyu  on 24/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import IQKeyboardManagerSwift

import Fakery


final class VCxReportDetail: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var closeButton: UIButton!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var cameraSnapshotView: UIImageView!
    
    @IBOutlet weak var videoView: PlayerView!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var txWhat: UITextField!
    
    @IBOutlet weak var txWho: UITextField!
    
    @IBOutlet weak var txWhen: UITextField!
    
    @IBOutlet weak var txWhere: UITextField!
    
    @IBOutlet weak var locationImageView: UIImageView!
    
    @IBOutlet weak var submitButton: UIButton!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    // MARK: Actions
    
    @IBAction func actOnCloseButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actOnEditButton(_ sender: UIButton) {
        
        guard let item = videoView.player?.currentItem else { return }
        
        let path = (item.asset as! AVURLAsset).url.path
        
        guard UIVideoEditorController.canEditVideo(atPath: path) else {
            print("can't edit video at \(path)")
            return
        }
        
        
        let editor = UIVideoEditorController()
        editor.videoPath = path
        editor.delegate  = self
        editor.videoQuality = .typeLow
        editor.videoMaximumDuration = 60
        
        present(editor, animated: true, completion: nil)
    }
    
    @IBAction func actOnPlayButton(_ sender: UIButton) {
        
        if let title = sender.currentTitle, title == "Play" {

            videoView.isHidden = false
            
            videoView.player?.seek(to: CMTime(seconds: 0.0, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            videoView.player?.play()
            playButton.setTitle("Stop", for: .normal)
            
            
            cameraSnapshotView.isHidden = true
        } else {
            
            
            
            videoView.player?.pause()
            playButton.setTitle("Play", for: .normal)
            cameraSnapshotView.isHidden = false
            
            videoView.isHidden = true
        }
    }
    
    @IBAction func actOnSubmitButton(_ sender: UIButton) {
        
//        ReportDetail.Act.Submit.dispatch()
        ReportDetail.store.dispatch( ReportDetail.thunk )
    }
    
    @IBAction func actOnDeleteButton(_ sender: UIButton) {
        
        ReportDetail.Act.Remove.dispatch()
    }
    
    
    // MARK: Life Cycles
    
    var sgstView: UIView?
    var _collectionView: UICollectionView?
    
    override func viewDidLoad() {
        
        txWhat.delegate = self
        txWho.delegate  = self
        
        // hehe, wow core ml
        sgstView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 48))
        sgstView?.backgroundColor = UIColor.lightGray
        
        
        let collectionViewlayout = UICollectionViewFlowLayout()
        collectionViewlayout.scrollDirection = .horizontal
        collectionViewlayout.estimatedItemSize = CGSize(width: 128, height: 38)
        
        let sgstCollectionView = UICollectionView(frame: sgstView!.frame, collectionViewLayout: collectionViewlayout)
        sgstCollectionView.backgroundColor = UIColor.groupTableViewBackground
        
        let nib = UINib(nibName: "WhoCell", bundle: nil)
        sgstCollectionView.register(nib, forCellWithReuseIdentifier: "WhoCell")
        
        sgstCollectionView.dataSource = self
        sgstCollectionView.delegate   = self
        
        sgstView!.addSubview(sgstCollectionView)
        
        let detectedLabel = UILabel()
        detectedLabel.text = "Detected"
        sgstView?.addSubview(detectedLabel)
        
        detectedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            detectedLabel.leadingAnchor.constraint(equalTo: sgstView!.leadingAnchor, constant: 8),
            detectedLabel.centerYAnchor.constraint(equalTo: sgstView!.centerYAnchor)
        ])
        
        sgstCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            sgstCollectionView.topAnchor.constraint(equalTo: sgstView!.topAnchor, constant: 1),
            sgstCollectionView.leadingAnchor.constraint(equalTo: detectedLabel.trailingAnchor, constant: 8),
            sgstCollectionView.trailingAnchor.constraint(equalTo: sgstView!.trailingAnchor),
            sgstCollectionView.bottomAnchor.constraint(equalTo: sgstView!.bottomAnchor)
        ])
        
        self._collectionView = sgstCollectionView
        
        txWho.inputAccessoryView = sgstView
        
        IQKeyboardManager.shared.enable = true
        
        videoView.isHidden = true
        
        progressBar.progress = 0
        progressBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        ReportDetail.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ReportDetail.store.unsubscribe(self)
    }
    
    // MARK: Properties
    
    // MARK: - ML Kit Vision Property
    lazy var vision = Vision.vision()
    lazy var textRecognizer = vision.onDeviceTextRecognizer()
    var visionText: VisionText?
    
    var sounder: AVPlayer?
    
    var suggestions: [String] = []
}

import ReSwift

extension VCxReportDetail: StoreSubscriber {
    
    func newState(state: ReportDetail.State) {
        
        // progress bar
        progressBar.isHidden = state.uploadProgress <= 0.0
        progressBar.setProgress(Float(state.uploadProgress), animated: true)
        
        
        if let report = state.report {
            
            txWhen.text = OurDateFormatter.string(from: report.when)
            
            if let location = report.whre {
                
                txWhere.text = "\(location.latitude), \(location.longitude)"
            }
            txWhat.text = report.what?.description
            txWho.text = report.who?.uppercased()
            
            if report.submitted == .notSubmitted {
                submitButton.isEnabled = true
            } else {
                submitButton.isEnabled = false
            }
            submitButton.setTitle(report.submitted.description.uppercased(), for: .normal)
            
            if report.submitted == .submitted {
                submitButton.setTitleColor(UIColor.white, for: .normal)
                submitButton.backgroundColor = UIColor(red: 0/255, green: 143/255, blue: 0, alpha: 1)
                
                progressBar.isHidden = true
                
                let alert = UIAlertController(title: "Thank You!",
                                              message: "Rewards: \(Faker().number.randomInt(min: 10, max: 100)) points.",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                
                self.present(alert, animated: true, completion: {
                    let soundUrl = Bundle.main.url(forResource: "cute-chirp2", withExtension: ".mp3")!
                    self.sounder = AVPlayer(url: soundUrl)
                    self.sounder?.play()
                })
            }
            
            
            // image cover            
            if let img = UIImage(contentsOfFile: report.how.photoUrl.path) {
                cameraSnapshotView.image = img
            }
            
            // set the video from url
            if let videoUrl = report.how.videoUrl {
                let player = AVPlayer(url: videoUrl)
                player.isMuted = true
                
                player.actionAtItemEnd = .pause
                
                videoView.player = player
                videoView.playerLayer.videoGravity = .resizeAspectFill
                
                playButton.isEnabled = true
                editButton.isEnabled = true
            } else {
                
                playButton.isEnabled = false
                editButton.isEnabled = false
                
                playButton.setTitle("no video", for: .normal)
            }
            
            // location image
            setLocationSnapshot(for: report.whre!)
            
        } else {
            
            playButton.isEnabled = false
            
            deleteButton.isHidden = true
            submitButton.isHidden = true
        }
        
        if let message = state.message {
        
            // QUESTION: why this get twice called?
            print("message: \(message)")
            

            
            let label = UILabel(frame: CGRect(x: 10, y: 60,
                                              width: self.view.frame.width-20, height: 60))
            label.text = message
            label.numberOfLines = 0
            label.textColor = UIColor.white
            label.backgroundColor = UIColor.red
            label.alpha = 0
            label.sizeToFit()
            
            
            self.view.addSubview(label)
            
            
            
            UIView.animate(withDuration: 1, animations: {
                label.alpha = 0.65
            }, completion: { _ in
                UIView.animate(withDuration: 2, animations: {
                    label.alpha = 0
                }, completion: { _ in
                    label.removeFromSuperview()
                })
            })
            
        }
        
        
    }
}

// MARK: VideoEditor Delegate

extension VCxReportDetail: UINavigationControllerDelegate, UIVideoEditorControllerDelegate {
    
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        
        editor.dismiss(animated: true, completion: nil)
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        editor.dismiss(animated: true, completion: {
            
            print("edited video is in \(editedVideoPath)")
            
            
            let editedVideoUrl = URL(fileURLWithPath: editedVideoPath)
            ReportDetail.Act.UpdateVideo(editedVideoUrl).dispatch()
        })
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        
        editor.dismiss(animated: true, completion: {
            
            print("Uh oh! There was an error \(error.localizedDescription)")
        })
    }
}

// MARK: TextFields Delegate

extension VCxReportDetail: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if textField == txWho, let img = cameraSnapshotView.image {
            predictImage(image: img)
        }
        
        guard textField == txWhat else { return true }
        
        // create dialog
        let annoyancesSelectionDialog = UIAlertController(title: "What",
                                                          message: "",
                                                          preferredStyle: .alert)
        
        // setup actions
        let opt1 = UIAlertAction(title: Annoyance.littering.description,
                                 style: .default,
                                 handler: { act in
                                    ReportDetail.Act.UpdateWhat(.littering).dispatch()
        })
        
        let opt2 = UIAlertAction(title: Annoyance.smoking.description,
                                 style: .default,
                                 handler: { act in
                                    ReportDetail.Act.UpdateWhat(.smoking).dispatch()
        })
        
        let opt3 = UIAlertAction(title: Annoyance.illegalParking.description,
                                 style: .default,
                                 handler: { act in
                                    ReportDetail.Act.UpdateWhat(.illegalParking).dispatch()
        })
        
        let opt4 = UIAlertAction(title: Annoyance.other("Lainnya").description,
                                 style: .default,
                                 handler: { act in
                                    ReportDetail.Act.UpdateWhat(.other("Lainnya")).dispatch()
        })
        
        let cancelOpt = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        // add actions
        annoyancesSelectionDialog.addAction(opt1)
        annoyancesSelectionDialog.addAction(opt2)
        annoyancesSelectionDialog.addAction(opt3)
        annoyancesSelectionDialog.addAction(opt4)
        annoyancesSelectionDialog.addAction(cancelOpt)
        
        // show dialog
        present(annoyancesSelectionDialog, animated: true, completion: nil)
        
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        if let text = textField.text, !text.isEmpty {
            
            // this is it
            ReportDetail.Act.UpdateWho(text).dispatch()
        }
        
        return true
    }
    
}


extension VCxReportDetail: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WhoCell", for: indexPath) as! WhoCell
        
        cell.label.text = suggestions[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        ReportDetail.Act.UpdateWho(suggestions[indexPath.item]).dispatch()
        txWho.resignFirstResponder()
    }
}


// MARK: Helper

import CoreLocation
import Firebase

extension VCxReportDetail {
    
    func setLocationSnapshot(for location: CLLocationCoordinate2D) {
        
        MapCache.shared.thumbnail(for: location, view: locationImageView)
        
    }
    
    func predictImage(image: UIImage) {
        
        UIGraphicsBeginImageContext(image.size)
        image.draw(at: .zero)
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let visionImage = VisionImage(image: fixedImage ?? image)
        textRecognizer.process(visionImage) { (vtext: VisionText?, error: Error?) in
            
            guard error == nil else {
                print(error!)
                return
            }
            
            if let visionText = vtext {
                
                self.visionText = visionText
                
                
                let detecteds = visionText.text.split(separator: "\n")
                print("DETECTED:", detecteds)
                
                self.suggestions = detecteds.map { String($0) }
                self._collectionView?.reloadData()
            }
            
            
        }
    }
}
