import Foundation
import ComposableArchitecture
import Combine

// TODO on language change predownload translation model in TranslationClient.
// TODO on target language change in snap detail, restart translation with fresh target language.
struct LanguageRepository {
    
    var setSourceLanguage: (Language) async -> Void
    var fetchSourceLanguage: () async -> Language

    var didChangeLanguage: AnyPublisher<Void, Never>
    var didChangeLanguageStream: AsyncStream<Void> {
        AsyncStream { continuation in
            let cancellable = self.didChangeLanguage
                .sink { continuation.yield($0) }
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }
    
    var didChangeSourceLanguage: AnyPublisher<Void, Never>
    
    var didChangeSourceLanguageStream: AsyncStream<Void> {
        AsyncStream { continuation in
            let cancellable = self.didChangeSourceLanguage.sink { continuation.yield($0) }
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }

    var setTargetLanguage: (Language) async -> Void
    var fetchTargetLanguage: () async -> Language
    
    var didChangeTargetLanguage: AnyPublisher<Void, Never>
    
    var didChangeTargetLanguageStream: AsyncStream<Void> {
        AsyncStream { continuation in
            let cancellable = self.didChangeTargetLanguage.sink { continuation.yield($0) }
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }

}

extension LanguageRepository: DependencyKey {
    static let liveValue: LanguageRepository = {
        let repository = Repository()
        let didChangeCurrentLanguageSubject = PassthroughSubject<Void, Never>()
        let didChangeTargetLanguageSubject = PassthroughSubject<Void, Never>()
        let didChangeLanguage = PassthroughSubject<Void, Never>()
        
        return LanguageRepository(
            setSourceLanguage: { language in
                let targetLanguage = await repository.targetLanguage
                let sourceLanguage = await repository.sourceLanguage
                if language == targetLanguage {
                    await repository.setTargetLanguage(sourceLanguage)
                    await repository.setSourceLanguage(targetLanguage)
                
                    let translateAllWordsToTargetLanguageUseCase = TranslateAllWordsToTargetLanguageUseCase()
                    await translateAllWordsToTargetLanguageUseCase.run()
                    
                    didChangeCurrentLanguageSubject.send(())
                    didChangeTargetLanguageSubject.send(())
                } else {
                    await repository.setSourceLanguage(language)
                    
                    let translateAllWordsToTargetLanguageUseCase = TranslateAllWordsToTargetLanguageUseCase()
                    await translateAllWordsToTargetLanguageUseCase.run()
                    
                    didChangeCurrentLanguageSubject.send(())
                }
                didChangeLanguage.send(())
            },
            fetchSourceLanguage: {
                return await repository.sourceLanguage
            },
            didChangeLanguage: didChangeLanguage
                .share()
                .eraseToAnyPublisher(),
            didChangeSourceLanguage: didChangeCurrentLanguageSubject
                .share()
                .eraseToAnyPublisher(),
            setTargetLanguage: { language in
                let targetLanguage = await repository.targetLanguage
                let sourceLanguage = await repository.sourceLanguage
                if language == sourceLanguage {
                    await repository.setTargetLanguage(sourceLanguage)
                    await repository.setSourceLanguage(targetLanguage)
                    
                    let translateAllWordsToTargetLanguageUseCase = TranslateAllWordsToTargetLanguageUseCase()
                    await translateAllWordsToTargetLanguageUseCase.run()
                    
                    didChangeCurrentLanguageSubject.send(())
                    didChangeTargetLanguageSubject.send(())
                } else {
                    await repository.setTargetLanguage(language)
                    
                    let translateAllWordsToTargetLanguageUseCase = TranslateAllWordsToTargetLanguageUseCase()
                    await translateAllWordsToTargetLanguageUseCase.run()
                    
                    didChangeTargetLanguageSubject.send(())
                }
                didChangeLanguage.send(())
            },
            fetchTargetLanguage: {
                return await repository.targetLanguage
            },
            didChangeTargetLanguage: didChangeTargetLanguageSubject
                .share()
                .eraseToAnyPublisher()
        )
    }()
}

extension DependencyValues {
    var languageRepository: LanguageRepository {
        get { self[LanguageRepository.self] }
        set { self[LanguageRepository.self] = newValue }
    }
}

private actor Repository {
    
    enum Constants {
        static let sourceLanguage = "sourceLanguage"
        static let targetLanguage = "targetLanguage"
    }
    
    var sourceLanguage: Language
    var targetLanguage: Language
    
    init() {
        self.sourceLanguage = Language(rawValue: UserDefaults.standard.string(forKey: Constants.sourceLanguage) ?? "") ?? .german
        self.targetLanguage = Language(rawValue: UserDefaults.standard.string(forKey: Constants.targetLanguage) ?? "") ?? .english
    }
    
    func setSourceLanguage(_ language: Language) -> Void {
        sourceLanguage = language
        UserDefaults.standard.set(sourceLanguage.rawValue, forKey: Constants.sourceLanguage)
    }

    func setTargetLanguage(_ language: Language) -> Void {
        targetLanguage = language
        UserDefaults.standard.set(targetLanguage.rawValue, forKey: Constants.targetLanguage)
    }
}
