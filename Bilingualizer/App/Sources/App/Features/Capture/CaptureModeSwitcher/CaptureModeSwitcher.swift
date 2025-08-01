import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct CaptureModeSwitcher {
    
    enum Mode: Equatable {
        case camera
        case textInput
        case speechInput
        case none
    }
    
    @ObservableState
    struct State: Equatable {
        var mode: Mode = .none
        var textInput: String = ""
        var camera: CameraMode.State = .init()
        var isCameraSheetPresented: Bool = false
    }
    
    enum Action: Equatable {
        enum TextInputAction: Equatable {
            case setText(String)
            case cancel
            case confirm
        }
        
        case setMode(Mode)
        
        case textInput(TextInputAction)
        case camera(CameraMode.Action)
        case setCameraSheetPresented(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.camera, action: \.camera) {
            CameraMode()
        }
        
        Reduce { state, action in
            switch action {
            case let .setMode(mode):
                if mode == .textInput {
                    state.textInput = .init()  // Reset text input state
                }
                state.mode = mode
                if mode == .camera {
                    state.isCameraSheetPresented = true  // Open sheet
                }
                return .none
                
            case .setCameraSheetPresented(let isPresented):
                state.isCameraSheetPresented = isPresented  // Toggle sheet
                if !isPresented {
                    state.mode = .none  // Reset mode when closing
                }
                return .none
            
            case .textInput(.setText(let newText)):
                state.textInput = newText
                return .none

            case .textInput(.cancel):
                return .send(.setMode(.none))
                
            case .camera(.cancel):
                return .send(.setMode(.none))
                
            case .textInput, .camera:
                return .none // These are handled by the respective reducers
            }
        }
    }
}
