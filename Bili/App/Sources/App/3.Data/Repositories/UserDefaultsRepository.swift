import Foundation

@MainActor
protocol UserDefaultsRepository: AnyObject {
    var currentFromLanguage: String? { get set }
    var currentToLanguage: String? { get set }
}

@MainActor
final class UserDefaultsRepositoryImpl: UserDefaultsRepository {
    private let defaults = UserDefaults.standard
    
    private enum Keys {
        static let currentFromLanguage = "currentFromLanguage"
        static let currentToLanguage = "currentToLanguage"
    }
    
    var currentFromLanguage: String? {
        get { defaults.string(forKey: Keys.currentFromLanguage) }
        set { defaults.setValue(newValue, forKey: Keys.currentFromLanguage) }
    }
    
    var currentToLanguage: String? {
        get { defaults.string(forKey: Keys.currentToLanguage) }
        set { defaults.setValue(newValue, forKey: Keys.currentToLanguage) }
    }
}

@MainActor
final class MockUserDefaultsRepository: UserDefaultsRepository {
    var currentFromLanguage: String?
    var currentToLanguage: String?
    
    init(
        from: String? = nil,
        to: String? = nil
    ) {
        self.currentFromLanguage = from
        self.currentToLanguage = to
    }
}

//extension UserDefaultsRepository: DependencyKey {
//    static var liveValue: UserDefaultsRepository {
//        UserDefaultsRepositoryImpl()
//    }
//}
//
//extension DependencyValues {
//    var userDefaultsRepository: UserDefaultsRepository {
//        get { self[UserDefaultsRepository.self] }
//        set { self[UserDefaultsRepository.self] = newValue }
//    }
//}
