import Foundation
import ComposableArchitecture
import NaturalLanguage
import SwiftUI
import Combine

@Reducer
struct CaptureNewWords {
    
    @ObservableState
    struct State: Equatable {
        enum Filter: LocalizedStringKey, CaseIterable, Hashable {
            case active = "Active"
            case archived = "Archived"
        }
        let sourceLanguage: Language
        let targetLanguage: Language
        var items: IdentifiedArrayOf<WordRow.State> = [] {
            didSet {
                activeItems = items.filter { !$0.isArchived }
                archivedItems = items.filter { $0.isArchived }
            }
        }
        var activeItems: IdentifiedArrayOf<WordRow.State> = []
        var archivedItems: IdentifiedArrayOf<WordRow.State> = []
        
        // Sub-reducers
        var cameraTextDetector: CameraTextDetector.State = .init(detectedWords: [])
    }
    
    enum Action: Equatable {
        
        case didLoad
        case cameraTextDetector(CameraTextDetector.Action)
        
        case _subscribeToFoundWords
        case _didUpdateFoundWords(Set<Word>)
        
        case items(IdentifiedActionOf<WordRow>)
    }
    
    private enum CancelID {
        case subscribedToFoundWords
    }
    
    let captureNewWordsRepository: CaptureNewWordsRepository
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .didLoad:
                return .send(._subscribeToFoundWords)
                
            case .cameraTextDetector(.receivedNewPhoto):
                return .none
                
            case .cameraTextDetector(.foundWords(let foundWordsStrings)):
                return .run { send in
                    await self.captureNewWordsRepository.enqueueCapturedWords(foundWordsStrings)
                }
                
            case ._subscribeToFoundWords:
                return .run { send in
                        for await words in await self.captureNewWordsRepository.didUpdateFoundWordsStream {
                            await send(._didUpdateFoundWords(words))
                        }
                    }
                    .cancellable(id: CancelID.subscribedToFoundWords)
                
            case ._didUpdateFoundWords(let words):
                var items: IdentifiedArrayOf<WordRow.State> = []
                let sortedWords: [Word] = Array(words).sorted { $0.updatedAt < $1.updatedAt }
                for word in sortedWords {
                    let item = WordRow.State(
                        word: word,
                        sourceLanguage: state.sourceLanguage,
                        targetLanguage: state.targetLanguage
                    )
                    items.append(item)
                }
                state.items = items
                return .none
            
            case .items:
                return .none
            }
        }
        ._printChanges()
        .forEach(\.items, action: \.items) {
            WordRow()
        }
        Scope(state: \.cameraTextDetector, action: \.cameraTextDetector) {
            CameraTextDetector()
        }
    }
}

//public protocol TCAFeatureAction {
//    associatedtype ViewAction
//    associatedtype DelegateAction
//    associatedtype InternalAction
//    
//    static func view(_: ViewAction) -> Self
//    static func delegate(_: DelegateAction) -> Self
//    static func `internal`(_: InternalAction) -> Self
//}
