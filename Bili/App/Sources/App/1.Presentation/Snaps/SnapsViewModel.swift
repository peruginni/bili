import Foundation
import UIKit

@MainActor
@Observable
final class SnapsViewModel {
    private let repository: SnapsRepository = DI.snapsRepository
    
    var snapIDs: [UUID] = []
    var isInputActive = false
    
    init() {
        reloadIDs()
    }
    
    func reloadIDs() {
        snapIDs = repository.getAllIDs()
    }

    func addSnap(_ snap: String) {
        repository.save(
            Snap(
                id: UUID(),
                text: snap,
                date: Date(),
                source: .typed,
                unknownWords: []
            )
        )
        isInputActive = false
        reloadIDs()
    }
    
    func addSnap(_ snap: UIImage) {
        repository.save(
            Snap(
                id: UUID(),
                text: "todo text from image",
                date: Date(),
                source: .photo,
                unknownWords: []
            )
        )
        isInputActive = false
        reloadIDs()
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
