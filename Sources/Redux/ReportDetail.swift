//
//  ReportDetail.swift
//  Public Eyes
//
//  Created by Fitsyu  on 26/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import ReSwift
import ReSwiftThunk

import CoreLocation

enum ReportDetail {
    
    struct State: StateType {
        
        var report: Report?
        var message: String?
        var uploadProgress: Double = 0.0
    }
    
    
    enum Act: Action {
        
        case Show(Report)
        
        case UpdateWhat(Annoyance)
        
        case UpdateWho(String)
        
        case UpdateVideo(URL)
        
        case UpdateSubmission(SubmissionStatus)
        
        case UpdateUploadProgress(Double)
        
        case Remove
        
        case ShowError(Error)
        
        func dispatch() {
            ReportDetail.store.dispatch(self)
        }
        
    }
    
    static func reduce(action: Action, state: State?) -> State {
        
        var state = state ?? State()
        
        guard let action = action as? Act else { return state }
        
        switch action {
            
        case .Show(let report):
            state.report = report
            
        case .UpdateWhat(let annoyance):
            state.report?.what = annoyance
            ReportsRepo.shared.update(report: state.report!)
            
        case .UpdateWho(let who):
            state.report?.who = who
            ReportsRepo.shared.update(report: state.report!)
            
        case .UpdateVideo(let url):
            state.report?.how.videoUrl = url
            ReportsRepo.shared.update(report: state.report!)
            
        case .UpdateSubmission(let status):
            state.report?.submitted = status
            ReportsRepo.shared.update(report: state.report!)
            
        case .UpdateUploadProgress(let value):
            state.uploadProgress = value
            
        case .ShowError(let error):
            state.message = error.localizedDescription
            
        case .Remove:
            ReportsRepo.shared.remove(state.report!)
            state.report = nil
            
        }
        
        return state
    }
    
    
    static let thunk = Thunk<State> { dispatch, getState in
        
        guard let state = getState() else { return }
        
        Act.UpdateSubmission(.submitting).dispatch()
        
        ReportsRepo.shared.upload(report: state.report!, progressHandler: {  Act.UpdateUploadProgress($0).dispatch() })
            .then { _ in
                
                Act.UpdateSubmission(.submitted).dispatch()
            }
            .catch { error in
                
                Act.ShowError(error).dispatch()
                Act.UpdateSubmission(.notSubmitted).dispatch()
        }
    
    }
    
    static let store = Store<State>(reducer: reduce, state: nil,
                                    middleware: [ createThunksMiddleware() ])
}
