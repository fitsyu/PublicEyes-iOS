//
//  ReportList.swift
//  Public Eyes
//
//  Created by Fitsyu  on 26/10/19.
//  Copyright © 2019 Fitsyu . All rights reserved.
//

import ReSwift

enum ReportList {
    
    struct State: StateType {
        
        var reports: [Report] = [] //Report.fakes()
        var isEditing: Bool = false
    }

    enum Act: Action {
        
        case Add(Report)
        case Show
        case Edit
        case RemoveSelected([Report])
        case RemoveAll
        case DoneEditing
        
        func dispatch() {
            ReportList.store.dispatch(self)
        }
    }

    static func reducer(action: Action, state: State?) -> State {
        
        var state = state ?? State()
        
        guard let action = action as? Act else { return state }
        
        switch action {
            
        case .Add(let report):
            ReportsRepo.shared.add(report)
            
        case .Show:
//            ReportsRepo.shared.fetch().then {
//                state.reports = $0
//            }
            state.reports = ReportsRepo.shared.fetchAll()
            
        case .Edit:
            state.isEditing = true
            
        case .RemoveSelected(let reports):
            state.reports.removeAll { reports.contains($0) }
            
        case .RemoveAll:
            state.reports.removeAll()

        case .DoneEditing:
            state.isEditing = false
            
        }
        
        return state
    }
    
    
    static let store = Store<State>(reducer: reducer, state: nil)
}
