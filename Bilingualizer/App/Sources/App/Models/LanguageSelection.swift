import Foundation

public struct LanguageSelection: Equatable, Codable {
    public let homeLanguage: Language
    public let foreignLanguage: Language
    
    public init(homeLanguage: Language, foreignLanguage: Language) {
        self.homeLanguage = homeLanguage
        self.foreignLanguage = foreignLanguage
    }
}

extension LanguageSelection {
    static var mock = LanguageSelection(homeLanguage: .english, foreignLanguage: .french)
}
