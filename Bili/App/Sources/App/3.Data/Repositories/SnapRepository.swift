import Foundation

protocol SnapsRepository: AnyObject {
    func getAllIDs() -> [UUID]
    func load(id: UUID) -> Snap?
    func save(_ snap: Snap)
    func delete(id: UUID)
}

final class InMemorySnapsRepository: SnapsRepository {
    private var store: [UUID: Snap] = [:]
    
    init() {
        preloadMockData()
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
    
    // Optional: preload with fake data
    func preloadMockData() {
        let snap1 = Snap(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            text: "The quick brown fox jumps over the lazy dog.",
            date: .now.addingTimeInterval(-300),
            source: .photo,
            unknownWords: ["quick", "lazy"]
        )
        let snap2 = Snap(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            text: "Language learning is more effective when it's fun.",
            date: .now.addingTimeInterval(-600),
            source: .typed,
            unknownWords: ["effective", "fun"]
        )
        
        save(snap1)
        save(snap2)
    }
}

final class MockSnapsRepository: SnapsRepository {
    let snap1 = Snap(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
        text: "The quick brown fox jumps over the lazy dog.",
        date: .now,
        source: .photo,
        unknownWords: ["quick", "lazy"]
    )
    let snap2 = Snap(
        id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
        text: "Language learning works best with repetition and fun.",
        date: .now.addingTimeInterval(-300),
        source: .typed,
        unknownWords: ["repetition", "fun"]
    )
    
    private var store: [UUID: Snap] = [:]
    
    init() {
        store[snap1.id] = snap1
        store[snap2.id] = snap2
        for i in 1...100 {
            let id = UUID()
            store[id] = Snap(
                id: id,
                text: "Language learning works best with repetition and fun.",
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
