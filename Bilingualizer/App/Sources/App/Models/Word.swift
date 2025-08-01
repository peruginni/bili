import Foundation

public struct Word: Identifiable, Equatable, Codable, Hashable {
    public var id: String { Self.makeIDFromWordAndLanguage(word, sourceLanguage) }
    public let word: String
    public let sourceLanguage: Language
    public var translations: [Language: String]
    public var createdAt: Date
    public var updatedAt: Date
    public var isArchived: Bool
    
    public init(word: String, sourceLanguage: Language, translations: [Language : String], createdAt: Date, updatedAt: Date, isArchived: Bool) {
        self.word = word
        self.sourceLanguage = sourceLanguage
        self.translations = translations
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isArchived = isArchived
    }
    
    public static func makeIDFromWordAndLanguage(_ word: String, _ language: Language) -> Word.ID {
        return "\(language.rawValue)_\(word)".lowercased()
    }
}
