import Foundation

@MainActor
@Observable
final class SnapItemViewModel {
    private let repository: SnapsRepository = DI.snapsRepository
    let id: UUID
    let onDelete: () -> Void
    
    var snap: Snap?
    var isLoading = false
    
    init(id: UUID, onDelete: @escaping () -> Void) {
        self.id = id
        self.onDelete = onDelete
        load()
    }

    func load() {
        isLoading = true
        snap = repository.load(id: id)
        isLoading = false
    }

    func archive(word: String) {
        // In-memory only: just remove from unknownWords for demo
        guard var snap = snap else { return }
        snap.unknownWords.removeAll { $0 == word }
        self.snap = snap
        repository.save(snap) // Persist updated version
    }

    func delete() {
        repository.delete(id: id)
        onDelete()
    }
}
