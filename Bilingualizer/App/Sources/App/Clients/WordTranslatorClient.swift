import Foundation
import ComposableArchitecture
import Combine

//public struct WordTranslatorClient {
//    
//    struct Word: Equatable, Identifiable {
//        var id: String { word }
//        let word: String
//        let translation: String?
//        let isGoogleTranslation: Bool
//    }
//    
//    var translateWordsIfNeeded: () async -> Void
//    
//    var didChangeWordTranslations: AnyPublisher<Void, Never>
//    var didChangeWordTranslationsStream: AsyncStream<Void> {
//        AsyncStream { continuation in
//            let cancellable = self.didChangeWordTranslations
//                .sink { continuation.yield($0) }
//            continuation.onTermination = { continuation in
//                cancellable.cancel()
//            }
//        }
//    }
//    
//}
//
//extension WordTranslatorClient: TestDependencyKey {
//    public static let testValue = Self(
//        translateWordsIfNeeded: { },
//        didChangeWordTranslations: PassthroughSubject<Void, Never>().eraseToAnyPublisher()
//    )
//    public static let previewValue = Self(
//        translateWordsIfNeeded: { },
//        didChangeWordTranslations: PassthroughSubject<Void, Never>().eraseToAnyPublisher()
//    )
//}
//
//public extension DependencyValues {
//    var wordTranslatorClient: WordTranslatorClient {
//        get { self[WordTranslatorClient.self] }
//        set { self[WordTranslatorClient.self] = newValue }
//    }
//}
//
//extension WordTranslatorClient: DependencyKey {
//    public static let liveValue: WordTranslatorClient = {
//        @Dependency(\.wordRepository) var wordRepository
//        @Dependency(\.languageRepository) var languageRepository
//        @Dependency(\.translationClient) var translationClient
//        
//        let didChangeWordTranslationsSubject = PassthroughSubject<Void, Never>()
//        let instance = Self(
//            translateWordsIfNeeded: {
//                await translateAllWordsToTargetLanguage(translationClient, languageRepository, wordRepository)
//                didChangeWordTranslationsSubject.send(())
//            },
//            didChangeWordTranslations: didChangeWordTranslationsSubject
//                .share()
//                .eraseToAnyPublisher()
//        )
//        return instance
//    }()
//}
