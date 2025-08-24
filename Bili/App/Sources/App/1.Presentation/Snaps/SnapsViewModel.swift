import Foundation
import UIKit

@MainActor
@Observable
final class SnapsViewModel {
    
    @ObservationIgnored
    @Injected(DI.snapsRepository) var repository
    
    var snaps: [SnapItemViewModel] = []
    var isInputActive = false
    
    init() {}
    
    func onAppear() {
        reload()
    }
    
    func reload() {
        snaps = repository.getAllIDs().map { id in
            SnapItemViewModel(id: id, loaded: nil)
        }
        snaps = snaps.map { snap in
            var snap = snap
            if let loadedSnap = repository.load(id: snap.id) {
                snap.loaded = .init(
                    text: loadedSnap.text,
                    image: loadedSnap.image,
                    source: loadedSnap.source
                )
            }
            return snap
        }
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
