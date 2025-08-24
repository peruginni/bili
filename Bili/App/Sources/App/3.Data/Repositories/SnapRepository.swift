import Foundation
import UIKit

protocol SnapsRepository: AnyObject {
    func getAllIDs() -> [UUID]
    func load(id: UUID) -> Snap?
    func save(_ snap: Snap)
    func delete(id: UUID)
}

extension DI {
    static var snapsRepository = Factory<SnapsRepository> { InMemorySnapsRepository() }
}

final class InMemorySnapsRepository: SnapsRepository {
    private var store: [UUID: Snap] = [:]
    
    init() {
        
    }
    
    func getAllIDs() -> [UUID] {
        store.keys.sorted { lhs, rhs in
            (store[lhs]?.date ?? .distantPast) > (store[rhs]?.date ?? .distantPast)
        }
    }
    
    func load(id: UUID) -> Snap? {
        store[id]
    }
    
    func save(_ snap: Snap) {
        store[snap.id] = snap
    }
    
    func delete(id: UUID) {
        store.removeValue(forKey: id)
    }
}

final class MockSnapsRepository: SnapsRepository {
    static let snap1 = Snap(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        text: nil,
        image: UIImage(systemName: "camera")!,
        date: .now,
        source: .photo,
        unknownWords: ["quick", "lazy"]
    )
    static let snap2 = Snap(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        text: "Language learning works best with repetition and fun.",
        image: nil,
        date: .now.addingTimeInterval(-300),
        source: .typed,
        unknownWords: ["repetition", "fun"]
    )
    
    private var store: [UUID: Snap] = [:]
    
    init() {
        store[Self.snap1.id] = Self.snap1
        store[Self.snap2.id] = Self.snap2
        for i in 1...100 {
            let id = UUID()
            store[id] = Snap(
                id: id,
                text: "Language learning works best with repetition and fun.",
                image: nil,
                date: .now.addingTimeInterval(-3000.0 - Double(i)),
                source: .typed,
                unknownWords: ["repetition", "fun"]
            )
        }
    }
    
    func getAllIDs() -> [UUID] {
        store.keys.sorted { lhs, rhs in
            (store[lhs]?.date ?? .distantPast) > (store[rhs]?.date ?? .distantPast)
        }
    }
    
    func load(id: UUID) -> Snap? {
        store[id]
    }
    
    func save(_ snap: Snap) {
        store[snap.id] = snap
    }
    
    func delete(id: UUID) {
        store.removeValue(forKey: id)
    }
}
