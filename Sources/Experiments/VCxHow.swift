//
//  DetailedHowViewController.swift
//  Public Eyes
//
//  Created by Fitsyu  on 24/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import UIKit

import ReSwift

enum ProofTune {
    
    struct State: StateType {
        
        var videoUrl: URL? = Bundle.main.url(forResource: "trim", withExtension: ".mp4")
        
        var isPlaying: Bool = false
    }
    
    enum Act: Action {
        
        case Show(URL)
        
        case Update(URL)
        
        case Play
        
        case Pause
        
        func dispatch() {
            ProofTune.store.dispatch(self)
        }
    }
    
    static func reducer(action: Action, state: State?) -> State {
        
        var state = state ?? State()
        
        guard let action = action as? Act else { return state }
        
        switch action {
            
        case .Show(let url):
            state.videoUrl = url
            
        case .Update(let url):
            state.videoUrl = url
            
        case .Play:
            state.isPlaying = true
            
        case .Pause:
            state.isPlaying = false
        }
        
        return state
    }
    
    static let store = Store<State>(reducer: reducer, state: nil)
}

// -----------------------------------------------------------------------

final class VCxHow: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var videoView: PlayerView!
    
    @IBOutlet weak var framesView: UIView!
    
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var playButton: UIButton!
    
    // MARK: Actions
    
    @IBAction func actOnCancelButton(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actOnDoneButton(_ sender: UIButton) {
        
        // save the updated
        // get the url
        // and notify
        // ProofTune.Act.Update(<#T##URL#>)
        
//        dismiss(animated: true, completion: nil)
        
//        guard let vidInBundleUrl = Bundle.main.url(forResource: "vid1", withExtension: ".mp4") else { return }
//
//        guard let cachesUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
//
//        let vidInCacheUrl = cachesUrl.appendingPathComponent("vid1").appendingPathExtension("mp4")
//
//        // copy
//        do {
//            try FileManager.default.copyItem(at: vidInBundleUrl, to: vidInCacheUrl)
//
//
//
//            let contents = try FileManager.default.contentsOfDirectory(atPath: cachesUrl.path)
//            dump(contents)
//
//            print(vidInCacheUrl)
//
//                if UIVideoEditorController.canEditVideo(atPath: vidInCacheUrl.path) {
//
//                    let editor = UIVideoEditorController()
//                    editor.videoPath = vidInCacheUrl.path
//                    editor.delegate = self
//                    present(editor, animated: true, completion: nil)
//                } else {
//                    print("can't edit")
//                }
//
//        } catch {
//            print(error)
//        }
        
        
        guard let vidInBundleUrl = Bundle.main.path(forResource: "vid1", ofType: "mp4") else { return }
        
        print(vidInBundleUrl)
        
        if UIVideoEditorController.canEditVideo(atPath: vidInBundleUrl) {
            
            let editor = UIVideoEditorController()
            editor.videoPath = vidInBundleUrl
            editor.delegate = self
            present(editor, animated: true, completion: nil)
        } else {
            print("can't edit")
        }

    }
    
    @IBAction func actOnSlider(_ sender: UISlider) {
        
        guard let player = videoView.player, let item = player.currentItem else { return }
        
        player.pause()

        let value = Double(slider.value * Float(item.duration.seconds))
        let point = CMTime(seconds: value, preferredTimescale: 1_000)
        
        seek(to: point)
    }
    
    
    @IBAction func actOnPlayButton(_ sender: UIButton) {
        
        if let title = sender.currentTitle, title == "Play" {
            
            videoView.player?.play()
            ProofTune.Act.Play.dispatch()
            
        } else {
            
            videoView.player?.pause()
            ProofTune.Act.Pause.dispatch()
        }
    }
    
    // MARK: Life Cycles
    
    override func viewWillAppear(_ animated: Bool) {
        
        ProofTune.store.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ProofTune.store.unsubscribe(self)
    }
    
    // MARK: Properties
    
    lazy internal var player: AVPlayer? = { return videoView.player }()
    
    private var isSeekInProgress = false
    private var chaseTime = CMTime.zero
    
    public func seek(to time: CMTime) {
        seekSmoothlyToTime(newChaseTime: time)
    }
    
    private func seekSmoothlyToTime(newChaseTime: CMTime) {
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime
            
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    private func trySeekToChaseTime() {
        guard player?.status == .readyToPlay else { return }
        actuallySeekToTime()
    }
    
    private func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        
        player?.seek(to: seekTimeInProgress, toleranceBefore: .zero, toleranceAfter: .zero) { [weak self] _ in
            guard let `self` = self else { return }
            
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime()
            }
        }
    }

}

import AVFoundation

extension VCxHow: StoreSubscriber {
    
    func newState(state: ProofTune.State) {
        
        // set the video from url
        if let url = state.videoUrl, videoView.player == nil {
        
            let player = AVPlayer(url: url)
            player.isMuted = true
            
            player.actionAtItemEnd = .pause
            
            
            player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 1, preferredTimescale: 1000), queue: .main) { (time: CMTime) in

                guard let item = player.currentItem else { return }
                
                let point = player.currentTime().seconds / item.asset.duration.seconds
                self.slider.setValue(Float(point), animated: true)
            }
            
            videoView.player = player
            
            
            
            slider.value = 0
            
        }
        
        let title = state.isPlaying ? "Pause" : "Play"
        playButton.setTitle(title, for: .normal)
    }
}


extension VCxHow: UIVideoEditorControllerDelegate {
    
    func videoEditorControllerDidCancel(_ editor: UIVideoEditorController) {
        
        print("cancel")
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didSaveEditedVideoToPath editedVideoPath: String) {
        
        print("edited")
    }
    
    func videoEditorController(_ editor: UIVideoEditorController, didFailWithError error: Error) {
        
        print("error")
    }
}


extension VCxHow: UINavigationControllerDelegate {
    
}
