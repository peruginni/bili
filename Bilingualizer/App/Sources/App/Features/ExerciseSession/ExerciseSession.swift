import Foundation
import SwiftUI
import ComposableArchitecture
import Speech

struct ExerciseSession: Reducer {
    
    struct State: Equatable {
        var sourceLanguage: Language
        var translationLanguage: Language
        
        enum Phase: Equatable {
            case idle
            case readingOriginal(iteration: UInt)
            case readingTranslation(iteration: UInt)
            
            var iteration: UInt? {
                switch self {
                case .idle:
                    return nil
                case .readingOriginal(let iteration):
                    return iteration
                case .readingTranslation(let iteration):
                    return iteration
                }
            }
        }
        
        struct WordViewModel: Identifiable, Equatable {
            let id: Word.ID
            let source: String
            let translation: String?
        }
        
        var allowReading: Bool = false
        var phase: Phase = .idle
        
        var allWords: [WordViewModel]
        var pastWords: [WordViewModel] = []
        var currentWord: WordViewModel? = nil
        var nextWords: [WordViewModel] = []
        
        var archivedWords: Set<Word.ID> = []
        var isArchivedWord: Bool {
            guard let id = currentWord?.id else { return false }
            return archivedWords.contains(id)
        }
        var autoContinue: Bool = true
        var maxIterationsPerWord: Int = 2
        
        var totalWordsCount: Int { (pastWords.count + nextWords.count + (currentWord == nil ? 0 : 1)) }
        var progress: Float { Float(pastWords.count) / Float(totalWordsCount) }
    }
    
    enum Action: Equatable {
        case shuffle
        case prevWord
        case nextWord
        case toggleArchiveForCurrentWord
        case stopReading
        case readOriginal(iteration: UInt)
        case readTranslation
        case didFinishIteration
        case toggleAutoContinue(Bool)
        case didLoad
        case didDisappear
        case didAppear
    }
    
    private enum CancelID { case reading }
    
    @Dependency(\.speechClient) var speechClient
    @Dependency(\.wordRepository) var wordRepository
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .didLoad:
                state.allowReading = true
                return .send(.shuffle)
                
            case .shuffle:
                state.phase = .idle
                state.pastWords = []
                state.currentWord = nil
                state.nextWords = Array(state.allWords.shuffled())
                return .send(.nextWord)
                
            case .prevWord:
                guard !state.pastWords.isEmpty else { return .none }
                
                speechClient.reset()
                
                if let currentWord = state.currentWord {
                    state.nextWords = [currentWord] + state.nextWords
                }
                state.currentWord = state.pastWords.popLast()
                state.phase = .idle
                
                if state.currentWord != nil {
                    return .concatenate(
                        .cancel(id: CancelID.reading),
                        .send(.readOriginal(iteration: 1))
                    )
                } else {
                    return .none
                }
                
            case .toggleArchiveForCurrentWord:
                guard let id = state.currentWord?.id else { return .none }
                
                let didArchive: Bool
                if state.archivedWords.contains(id) {
                    didArchive = false
                    state.archivedWords.remove(id)
                } else {
                    didArchive = true
                    state.archivedWords.insert(id)
                }
                
                return .run { _ in
                    if didArchive {
                        await wordRepository.archiveWord(id)
                    } else {
                        await wordRepository.unarchiveWord(id)
                    }
                }
                
            case .nextWord:
                speechClient.reset()
                
                if let currentWord = state.currentWord {
                    state.pastWords.append(currentWord)
                }
                state.currentWord = state.nextWords.popLast()
                state.phase = .idle
                
                if state.currentWord != nil {
                    return .concatenate(
                        .cancel(id: CancelID.reading),
                        .send(.readOriginal(iteration: 1))
                    )
                } else {
                    return .none
                }
                
            case .readOriginal(let iteration):
                guard
                    state.allowReading == true,
                    let currentWord = state.currentWord
                else { return .none }
                
                state.phase = .readingOriginal(iteration: iteration)
                return .run { [state] send in
                    
                    await speechClient.sayTextInLanguage(currentWord.source, state.sourceLanguage)
                    
                    if currentWord.source.lowercased() != currentWord.translation?.lowercased() {
                        await send(.readTranslation)
                    } else {
                        await send(.didFinishIteration)
                    }
                }
                .cancellable(id: CancelID.reading)
                
            case .readTranslation:
                guard
                    state.allowReading == true,
                    let currentWord = state.currentWord,
                    let translation = currentWord.translation,
                    case .readingOriginal(let iteration) = state.phase
                else { return .none }
                
                state.phase = .readingTranslation(iteration: iteration)
                return .run { [state] send in
                    await speechClient.sayTextInLanguage(translation, state.translationLanguage)
                    await send(.didFinishIteration)
                }
                .cancellable(id: CancelID.reading)
                
            case .didFinishIteration:
                
                guard state.autoContinue else {
                    return .none
                }
                
                if
                    let iteration = state.phase.iteration,
                    iteration < state.maxIterationsPerWord
                {
                    return .send(.readOriginal(iteration: iteration + 1))
                } else {
                    return .send(.nextWord)
                }
                
            case .stopReading:
                speechClient.reset()
                return .none
                
            case .toggleAutoContinue(let isOn):
                state.autoContinue = isOn
                return .none
                
            case .didAppear:
                state.allowReading = true
                return .none
                
            case .didDisappear:
                state.allowReading = false
                return .send(.stopReading)
            }
        }
    }
}

