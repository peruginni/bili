import Foundation
import ComposableArchitecture

public struct WordRepository {
    
    public enum Sort {
        case titleAsc
        case titleDesc
        case createdAsc
        case createdDesc
    }
    
    public struct StoreWordTranslation {
        public let wordID: Word.ID
        public let translationLanguage: Language
        public let translationText: String
        public init(wordID: Word.ID, translationLanguage: Language, translationText: String) {
            self.wordID = wordID
            self.translationLanguage = translationLanguage
            self.translationText = translationText
        }
    }
    
    public var storeWordsForLanguage: (Set<String>, Language) async -> Void
    public var storeWordTranslations: ([StoreWordTranslation]) async -> Void
    public var fetchWordsForLanguage: (Set<String>, Language) async -> [Word]
    public var fetchAllByLanguage: (Language) async -> [Word]
    public var archiveWord: (Word.ID) async -> Void
    public var unarchiveWord: (Word.ID) async -> Void
    public var deleteWord: (Word.ID) async -> Void
    
    public init(
        storeWordsForLanguage: @escaping (Set<String>, Language) async -> Void,
        storeWordTranslations: @escaping ([StoreWordTranslation]) async -> Void,
        fetchWordsForLanguage: @escaping (Set<String>, Language) async -> [Word],
        fetchAllByLanguage: @escaping (Language) async -> [Word],
        archiveWord: @escaping (Word.ID) async -> Void,
        unarchiveWord: @escaping (Word.ID) async -> Void,
        deleteWord: @escaping (Word.ID) async -> Void
    ) {
        self.storeWordsForLanguage = storeWordsForLanguage
        self.storeWordTranslations = storeWordTranslations
        self.fetchWordsForLanguage = fetchWordsForLanguage
        self.fetchAllByLanguage = fetchAllByLanguage
        self.archiveWord = archiveWord
        self.unarchiveWord = unarchiveWord
        self.deleteWord = deleteWord
    }
}

extension WordRepository: TestDependencyKey {
    public static var testValue: WordRepository {
        WordRepository(
            storeWordsForLanguage: { _, _ in },
            storeWordTranslations: { _ in },
            fetchWordsForLanguage: { _, _ in [] },
            fetchAllByLanguage: { _ in [] },
            archiveWord: { _ in },
            unarchiveWord: { _ in },
            deleteWord: { _ in }
        )
    }
}

extension DependencyValues {
    var wordRepository: WordRepository {
        get { self[WordRepository.self] }
        set { self[WordRepository.self] = newValue }
    }
}
