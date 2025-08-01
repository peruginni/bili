import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct WordRow: Reducer {
    
    struct State: Identifiable, Equatable {
        let id: Word.ID
        let originalLanguage: Language
        let originalText: String
        let translatedText: String
        var isArchived: Bool
        
        init(id: Word.ID, originalLanguage: Language, originalText: String, translatedText: String, isArchived: Bool) {
            self.id = id
            self.originalLanguage = originalLanguage
            self.originalText = originalText
            self.translatedText = translatedText
            self.isArchived = isArchived
        }
        
        init(word: Word, sourceLanguage: Language, targetLanguage: Language) {
            self.id = word.id
            self.originalLanguage = sourceLanguage
            self.originalText = word.word
            self.translatedText = word.translations[targetLanguage] ?? ""
            self.isArchived = word.isArchived
        }
    }
    
    enum Action: Equatable {
        case tapRow
        case archive
        case unarchive
        case delete
    }
    
    @Dependency(\.translationClient) var translationClient
    @Dependency(\.wordRepository) var wordRepository
    @Dependency(\.speechClient) var speechClient
    
    private enum CancelID {
        case reading
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .tapRow:
                let state = state
                return .concatenate(
                    .cancel(id: CancelID.reading),
                    .run { _ in
                        await speechClient.sayTextInLanguage(state.originalText, state.originalLanguage)
                    }
                    .cancellable(id: CancelID.reading)
                )
                
            case .archive:
                let id = state.id
                state.isArchived = true
                return .run { send in
                    await wordRepository.archiveWord(id)
                }
                
            case .unarchive:
                let id = state.id
                state.isArchived = false
                return .run { send in
                    await wordRepository.unarchiveWord(id)
                }
                
            case .delete:
                let id = state.id
                return .run { send in
                    await wordRepository.deleteWord(id)
                }
            }
        }
    }
}
