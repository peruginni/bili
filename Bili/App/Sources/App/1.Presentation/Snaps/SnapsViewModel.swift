import Foundation

@MainActor
@Observable
final class SnapsViewModel {
    private let repository: SnapsRepository = DI.snapsRepository
    
    var snapIDs: [UUID] = []
    
    init() {
        reloadIDs()
    }
    
    func reloadIDs() {
        snapIDs = repository.getAllIDs()
    }
    
    func addSnap(_ snap: Snap) {
        repository.save(snap)
        reloadIDs()
    }
    
    func deleteSnap(id: UUID) {
        repository.delete(id: id)
        reloadIDs()
    }
}
