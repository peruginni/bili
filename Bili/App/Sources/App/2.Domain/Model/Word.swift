import Foundation

public struct Word: Identifiable, Equatable, Codable, Hashable {
    public let id: UUID
    public let word: String
    public let sourceLanguage: Language
    public let targetLanguage: Language
    public var translations: [String]
    public var createdAt: Date
    public var updatedAt: Date
    public var isArchived: Bool
}
