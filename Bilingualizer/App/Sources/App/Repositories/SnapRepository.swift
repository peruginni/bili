import Foundation
import ComposableArchitecture

public struct SnapRepository {
    
    public enum Sort {
        case titleAsc
        case titleDesc
        case createdAsc
        case createdDesc
    }
    
    public var store: (Snap) async -> Void
    public var fetch: (Snap.ID) async -> Snap?
    public var fetchAllByLanguage: (Language) async -> [Snap]
    public var delete: (Snap.ID) async -> Void
    public var isEmpty: () async -> Bool
    
    public init(
        store: @escaping (Snap) async -> Void,
        fetch: @escaping (Snap.ID) async -> Snap?,
        fetchAllByLanguage: @escaping (Language) async -> [Snap],
        delete: @escaping (Snap.ID) async -> Void,
        isEmpty: @escaping () async -> Bool
    ) {
        self.store = store
        self.fetch = fetch
        self.fetchAllByLanguage = fetchAllByLanguage
        self.delete = delete
        self.isEmpty = isEmpty
    }
}

extension SnapRepository: TestDependencyKey {
    public static var testValue: SnapRepository {
        return SnapRepository(
            store: { _ in
                
            },
            fetch: { _ in
                return nil
            },
            fetchAllByLanguage: { _ in
                return []
            },
            delete: { _ in 
                
            },
            isEmpty: { return false }
        )
    }
    
    
}

extension DependencyValues {
    public var snapRepository: SnapRepository {
        get { self[SnapRepository.self] }
        set { self[SnapRepository.self] = newValue }
    }
}

