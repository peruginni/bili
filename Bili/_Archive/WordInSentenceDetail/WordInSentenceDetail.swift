import Foundation
import ComposableArchitecture
import SwiftUI

struct WordInSentenceDetail: Reducer {
    
    struct State: Equatable {
        struct Sentence: Equatable {
            var text: String
            var language: Language
        }
        let sourceLanguage: Language
        let targetLanguage: Language
        var word: Word
        var wordOriginal: String { word.word }
        var wordTranslation: String? { word.translations[targetLanguage] }
        var originalSentence: Sentence
        var translatedSentence: Sentence?
    }
    
    enum Action: Equatable {
        case load
        case didTranslateSentence(State.Sentence)
        case archive
        case unarchive
        case wordChanged
    }
    
    @Dependency(\.translationClient) var translationClient
    @Dependency(\.languageRepository) var languageRepository
    @Dependency(\.wordRepository) var wordRepository
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                let targetLanguage = state.targetLanguage
                let originalSentence = state.originalSentence
                return .run { send in
                    let translatedSentence = State.Sentence(
                        text: (try? await translationClient.translateIdentifiedText([(UUID().uuidString, originalSentence.text)], originalSentence.language, targetLanguage).first?.value) ?? "",
                        language: targetLanguage
                    )
                    await send(.didTranslateSentence(translatedSentence))
                }
            case .didTranslateSentence(let translatedSentence):
                state.translatedSentence = translatedSentence
                return .none
                
            case .archive:
                state.word.isArchived = true
                let word = state.word
                return .run { send in
                    await wordRepository.archiveWord(word.id)
                    await send(.wordChanged)
                }
            case .unarchive:
                state.word.isArchived = false
                let word = state.word
                return .run { send in
                    await wordRepository.unarchiveWord(word.id)
                    await send(.wordChanged)
                }
            case .wordChanged:
                return .none
            }
        }
    }
}
