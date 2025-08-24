import Foundation

@MainActor
@Observable
final class SnapItemViewModel {
    
    @ObservationIgnored
    @Injected(DI.snapsRepository) var repository
    
    let id: UUID
    let onDelete: () -> Void
    
    var snap: Snap?
    var isLoading = false
    
    init(id: UUID, onDelete: @escaping () -> Void) {
        self.id = id
        self.onDelete = onDelete
        onAppear()
    }

    func onAppear() {
        print("ondra - SnapItemViewModel.onAppear - \(id)")
        isLoading = true
        snap = repository.load(id: id)
        print("ondra - SnapItemViewModel.onAppear - \(id) loaded \(snap?.text)")
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
