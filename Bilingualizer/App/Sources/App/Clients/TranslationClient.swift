import Foundation
import ComposableArchitecture

public struct TranslationClient {
    public typealias Input = [(ID, SourceText)]
    public typealias Output = [ID: TranslatedText]
    public typealias FromLanguage = Language
    public typealias ToLanguage = Language
    
    public typealias ID = String
    public typealias SourceText = String
    public typealias TranslatedText = String
    
    public var translateIdentifiedText: @Sendable (Input, FromLanguage, ToLanguage) async throws -> Output
    
    public init(translateIdentifiedText: @Sendable @escaping (Input, FromLanguage, ToLanguage) async throws -> Output) {
        self.translateIdentifiedText = translateIdentifiedText
    }
}

extension TranslationClient: TestDependencyKey {
    public static let testValue = Self(
        translateIdentifiedText: { input, _, _ in
            input
                .map { id, value in
                    (id, "Translated \(value)")
                }
                .reduce(into: [:]) { result, pair in
                    result[pair.0] = pair.1
                }
        }
    )
    public static let previewValue = testValue
}

public extension DependencyValues {
    var translationClient: TranslationClient {
        get { self[TranslationClient.self] }
        set { self[TranslationClient.self] = newValue }
    }
}
