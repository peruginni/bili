//
//  File.swift
//  
//
//  Created by Ondra on 18.11.2022.
//

import Foundation
import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

@Reducer
struct App: Reducer {
    
    struct State: Equatable {
        var languageSelection: LanguageSelection
        var captureScreen: CaptureScreen.State
    }
    
    enum Action: Equatable {
        case captureScreen(CaptureScreen.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.captureScreen, action: \.captureScreen) {
            CaptureScreen()
        }
        
        Reduce { state, action in
            switch action {
            case .captureScreen:
                return .none
            }
        }
    }
}

