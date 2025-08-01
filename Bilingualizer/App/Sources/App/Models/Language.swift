import Foundation

public enum Language: String, Equatable, CaseIterable, Identifiable, Codable {
    public var id: String { rawValue }
    
    case english = "en"
    case german = "de"
    case french = "fr"
    case italian = "it"
    case spanish = "sp"
    case czech = "cz"
    
    public var emoji: String {
        switch self {
        case .english:
            return "🇬🇧"
        case .german:
            return "🇩🇪"
        case .french:
            return "🇫🇷"
        case .italian:
            return "🇮🇹"
        case .spanish:
            return "🇪🇸"
        case .czech:
            return "🇨🇿"
        }
    }
    
    public var title: String {
        switch self {
        case .english:
            return "English"
        case .german:
            return "German"
        case .french:
            return "French"
        case .italian:
            return "Italian"
        case .spanish:
            return "Spanish"
        case .czech:
            return "Czech"
        }
    }
    
    public var recognitionLanguageCode: String {
        switch self {
        case .english:
            return "en-US"
        case .german:
            return "de-DE"
        case .french:
            return "fr-FR"
        case .italian:
            return "it-IT"
        case .spanish:
            return "es-ES"
        case .czech:
            return "cs-CZ"
        }
    }
}
