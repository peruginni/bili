//import Foundation
//import SwiftUI
//import ComposableArchitecture
//import Speech
//
//struct Exercises: Reducer {
//    
//    struct State: Equatable {
//        enum Phase {
//            case loading
//            case idle
//        }
//        var phase: Phase = .idle
//        var isSessionShown: Bool = false
//        var archivedWordsCount: Int = 0
//        var activeWordsCount: Int = 0
//        var numberOfWordsToExercise: Int = 50
//        var session: ExerciseSession.State?
//        var autoContinue: Bool = true
//    }
//    
//    enum Action: Equatable {
//        case didTapStart
//        case didAppear
//        case didDisappear
//        case didLoad(archived: Int, active: Int)
//        case didChangeNumberWordsToExerciseTo(Int)
//        case exerciseSessionPrepared(ExerciseSession.State)
//        case exerciseSessionAction(ExerciseSession.Action)
//        case exerciseSessionDismissed
//        case toggleAutoContinue
//        case refresh
//        case didChangeLanguage
//    }
//    
//    @Dependency(\.wordRepository) var wordRepository
//    @Dependency(\.languageRepository) var languageRepository
//
//    private enum CancelID { case listeningToLanguageChanges }
//
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//            case .didAppear:
//                return .merge(
//                    .send(.refresh),
//                    .run { send in
//                        for await _ in self.languageRepository.didChangeLanguageStream {
//                            await send(.didChangeLanguage)
//                        }
//                    }
//                    .cancellable(id: CancelID.listeningToLanguageChanges)
//                )
//                
//            case .didDisappear:
//                return .cancel(id: CancelID.listeningToLanguageChanges)
//                
//            case .refresh:
//                return .run { send in
//                    let sourceLanguage = await languageRepository.fetchSourceLanguage()
//                    let allWords = await wordRepository.fetchAllByLanguage(sourceLanguage)
//                    let activeCount = allWords.filter({ $0.isArchived == false }).count
//                    let archivedCount = max(0, allWords.count - activeCount)
//                    
//                    await send(.didLoad(archived: archivedCount, active: activeCount))
//                }
//                
//            case .didChangeLanguage:
//                return .send(.refresh)
//                
//            case .didLoad(let archived, let active):
//                state.archivedWordsCount = archived
//                state.activeWordsCount = active
//                
//                return .none
//                
//            case .didChangeNumberWordsToExerciseTo(let number):
//                state.numberOfWordsToExercise = number
//                return .none
//                
//            case .didTapStart:
//                state.phase = .loading
//                let maxWords = state.numberOfWordsToExercise
//                return .run { send in
//                    let sourceLanguage = await languageRepository.fetchSourceLanguage()
//                    let targetLanguage = await languageRepository.fetchTargetLanguage()
//                    let allWords = await wordRepository.fetchAllByLanguage(sourceLanguage)
//                    let selectedWords = allWords
//                        .filter({ $0.isArchived == false })
//                        .shuffled()
//                        .prefix(maxWords)
//                    let wordViewModels = selectedWords
//                        .map { word in
//                            ExerciseSession.State.WordViewModel(
//                                id: word.id,
//                                source: word.word,
//                                translation: word.translations[targetLanguage]
//                            )
//                        }
//                    
//                    let substate = ExerciseSession.State(
//                        sourceLanguage: sourceLanguage,
//                        translationLanguage: targetLanguage,
//                        allWords: wordViewModels
//                    )
//                    
//                    await send(.exerciseSessionPrepared(substate))
//                }
//                
//            case .exerciseSessionPrepared(let substate):
//                state.phase = .idle
//                state.session = substate
//                state.isSessionShown = true
//                return .none
//            
//            case .exerciseSessionAction(_):
//                return .none
//                
//            case .exerciseSessionDismissed:
//                state.isSessionShown = false
//                return .none
//                
//            case .toggleAutoContinue:
//                state.autoContinue = !state.autoContinue
//                return .none
//            }
//        }
//        .ifLet(\.session, action: /Action.exerciseSessionAction) {
//            ExerciseSession()
//        }
//    }
//}
