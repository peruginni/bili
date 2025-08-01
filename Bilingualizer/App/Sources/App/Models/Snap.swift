import Foundation

public struct Snap: Identifiable, Equatable, Codable {
    public let id: UUID
    public let language: Language
    public var words: Set<String>
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(id: UUID, language: Language, words: Set<String>, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.language = language
        self.words = words
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Snap {
    public static func makeDummy(language: Language = .german) -> Snap {
        Snap(
            id: UUID(),
            language: language,
            words: [
                "hallo", "guten", "tag", "wie", "geht", "es"
            ],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
