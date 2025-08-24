import Foundation
import UIKit

@MainActor
@Observable
final class SnapsViewModel {
    
    @ObservationIgnored
    @Injected(DI.snapsRepository) var repository
    
    var snapIDs: [UUID] = []
    var isInputActive = false
    
    init() {}
    
    func onAppear() {
        reload()
    }
    
    func reload() {
        snapIDs = repository.getAllIDs()
    }

    func addSnap(_ snap: String) {
        repository.save(
            Snap(
                id: UUID(),
                text: snap,
                image: nil,
                date: Date(),
                source: .typed,
                unknownWords: []
            )
        )
        isInputActive = false
        reload()
    }
    
    func addSnap(_ snap: UIImage) {
        repository.save(
            Snap(
                id: UUID(),
                text: nil,
                image: snap,
                date: Date(),
                source: .photo,
                unknownWords: []
            )
        )
        isInputActive = false
        reload()
    }
    
    func addSnap(_ snap: Snap) {
        repository.save(snap)
        reload()
    }
}
