import Foundation
import ComposableArchitecture

struct TranslateAllWordsToTargetLanguageUseCase {
    @Dependency(\.translationClient) var translationClient
    @Dependency(\.languageRepository) var languageRepository
    @Dependency(\.wordRepository) var wordRepository
    
    func run() async -> Void {
        let sourceLanguage = await languageRepository.fetchSourceLanguage()
        let targetLanguage = await languageRepository.fetchTargetLanguage()
        
        let words = await wordRepository.fetchAllByLanguage(sourceLanguage)
        
        await translateSelectedWords(
            words: words.map { .init(wordID: $0.id, wordInSourceLanguage: $0.word) },
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            translationClient,
            wordRepository
        )
    }
}
