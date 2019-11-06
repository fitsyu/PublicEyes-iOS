//
//  Hunt.swift
//  Public Eyes
//
//  Created by Fitsyu  on 26/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import ReSwift

enum Hunt {
    
    struct State: StateType {
        
        var title: String = ""
        
        var isHunting: Bool = false
        var isPreviewing: Bool = false
        var isFlipped: Bool = false
    }
    
    enum Act: Action {
        
        case Start
        case Stop
        
        case TogglePreviewing
        case ToggleFlip
        
        case Create(Report)
        
        func dispatch() {
            Hunt.store.dispatch(self)
        }
    }
    
    static func reducer(action: Action, state: State?) -> State {
        
        var state = state ?? State()
        
        guard let action = action as? Act else { return state }
        
        switch action {
            
        case .Start:
            state.title = "Hunting"
            state.isHunting = true
//            state.isPreviewing = true
            
        case .Stop:
            state.title = "Idle"
            state.isHunting = false
            
        case .TogglePreviewing:
            state.isPreviewing = !state.isPreviewing
            
        case .ToggleFlip:
            state.isFlipped = !state.isFlipped
            
        case .Create(let report):
            ReportsRepo.shared.add(report)
        }
        
        return state
    }
    
    static let store = Store<State>(reducer: reducer, state: nil)
}
