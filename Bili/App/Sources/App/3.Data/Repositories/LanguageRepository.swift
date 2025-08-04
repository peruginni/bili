import Combine

protocol LanguageRepository {
    var from: AnyPublisher<Language, Never> { get }
    var to: AnyPublisher<Language, Never> { get }
}

class LanguageRepositoryImpl: LanguageRepository {
    
    private let userDefaultsRepository: UserDefaultsRepository
    private let fromSubject: CurrentValueSubject<Language, Never>
    private let toSubject: CurrentValueSubject<Language, Never>
    
    let from: AnyPublisher<Language, Never>
    let to: AnyPublisher<Language, Never>
    
    init(userDefaultsRepository: UserDefaultsRepository) {
        self.userDefaultsRepository = userDefaultsRepository
        fromSubject = CurrentValueSubject(.english)
        toSubject = CurrentValueSubject(.german)
        from = fromSubject.eraseToAnyPublisher()
        to = toSubject.eraseToAnyPublisher()
    }
}
