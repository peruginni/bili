//import Foundation
//import ComposableArchitecture
//import SwiftUI
//
//struct SnapsAddNew: Reducer {
//    
//    struct State: Equatable {
//        enum Phase: Equatable {
//            case takingPhoto
//            case recognizingTextInImage(UIImage)
//            case showingSnap
//            case requestingDismiss
//        }
//        var snap: Snap
//        var phase: Phase
//        var snapDetail: SnapDetail.State?
//    }
//    
//    enum Action: Equatable {
//        case startTakingPhoto
//        case recognizeTextInPhoto(UIImage)
//        case updatedSnap(Snap)
//        case snapDetail(SnapDetail.Action)
//        case retakeLastOne
//        case addMore
//        case dismiss
//    }
//    
//    @Dependency(\.textRecognitionClient) var textRecognitionClient
//    @Dependency(\.languageRepository) var languageRepository
//    @Dependency(\.snapRepository) var snapRepository
//    @Dependency(\.wordRepository) var wordRepository
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//            case .startTakingPhoto:
//                state.phase = .takingPhoto
//                return .none
//                
//            case .recognizeTextInPhoto(let photo):
//                state.phase = .recognizingTextInImage(photo)
//                let language = state.snap.language
//                let snap = state.snap
//                return .run { send in
//                    let recognizedStrings = await textRecognitionClient.recognizeTextInImage(photo, language)
//                
//                    var snap = snap
//                    
//                    if !recognizedStrings.isEmpty {
//                        snap.rawCapturedParts.append(recognizedStrings)
//                    }
//                    
//                    if !snap.rawCapturedParts.isEmpty {
//                        /// Store snap
//                        (snap.sentences, snap.words) = extractSentencesAndWordsFromRawCapturedParts(snap.rawCapturedParts)
//                        await snapRepository.store(snap)
//                        
//                        /// Store words
//                        let wordsToStore = Set(
//                            snap.words
//                                .filter { $0.count > 3 } // Drop very small words, user can add them manually when needed.
//                        )
//                        await wordRepository.storeWordsForLanguage(wordsToStore, snap.language)
//                        
//                    }
//                    
//                    await send(.updatedSnap(snap))
//                }
//                
//            case .updatedSnap(let snap):
//                state.snap = snap
//                state.phase = .showingSnap
//                state.snapDetail = SnapDetail.State(snap: snap, sentences: [], words: [:], phase: .idle)
//                return .none
//                
//            case .snapDetail(let subaction):
//                switch subaction {
//                case .translateIfNeeded,
//                    .startTranslatingWordsIntoTargetLanguage(_, _),
//                    .refreshWords,
//                    .wordsRefreshed(_, _),
//                    .nameChanged(_),
//                    .didCreateWordOnTap,
//                    .wordInSentenceDetailTapped(_, _),
//                    .wordInSentenceDetailPreparedState(_),
//                    .wordInSentenceDetailAction(_),
//                    .wordInSentenceDetailDismissed,
//                    .saveChangedName,
//                    .didTapDelete,
//                    .dismiss:
//                    break
//                case .didTapRetake:
//                    return .send(.retakeLastOne)
//                case .didTapAddMore:
//                    return .send(.addMore)
//                }
//                return .none
//                
//            case .retakeLastOne:
//                state.snap.rawCapturedParts = state.snap.rawCapturedParts.dropLast(1)
//                state.phase = .takingPhoto
//                return .none
//                
//            case .addMore:
//                state.phase = .takingPhoto
//                return .none
//                
//            case .dismiss:
//                state.phase = .requestingDismiss
//                return .none
//            }
//        }
//        .ifLet(\.snapDetail, action: /Action.snapDetail) {
//            SnapDetail()
//        }
//    }
//}
