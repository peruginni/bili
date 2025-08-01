import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct CaptureScreen {
    @ObservableState
    struct State: Equatable {
        var languageSelection: LanguageSelection
        var captureModeSwitcher: CaptureModeSwitcher.State = .init()
        var capturedItems: IdentifiedArrayOf<CapturedItem.State> = []
    }
    
    enum Action: Equatable {
        case capturedItems(IdentifiedActionOf<CapturedItem>)
        case captureModeSwitcher(CaptureModeSwitcher.Action)
        case inputSubmitted(String)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.captureModeSwitcher, action: \.captureModeSwitcher) {
            CaptureModeSwitcher()
        }
        
        Reduce { state, action in
            switch action {
            case .captureModeSwitcher(.setMode):
                return .none
                
            case .captureModeSwitcher(.textInput(.confirm)):
                let newEntry = CapturedItem.State(
                    languageSelection: state.languageSelection,
                    text: state.captureModeSwitcher.textInput
                )
                state.capturedItems.insert(newEntry, at: 0)
                state.captureModeSwitcher.textInput = ""
                return .send(.capturedItems(.element(id: newEntry.id, action: .startProcessing)))
                
            case .captureModeSwitcher(.camera(.snapPhoto(let photo))):
                let newEntry = CapturedItem.State(languageSelection: state.languageSelection, photo: photo)
                state.capturedItems.insert(newEntry, at: 0)
                return .send(.capturedItems(.element(id: newEntry.id, action: .startProcessing)))
                
            case .capturedItems:
                return .none
                
            default:
                return .none
            }
        }
        .forEach(\.capturedItems, action: \.capturedItems) {
            CapturedItem()
        }
    }
}
