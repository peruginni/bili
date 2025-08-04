import Foundation

struct Snap: Identifiable, Equatable {
    let id: UUID
    let text: String
    let date: Date
    let source: SnapSource
    var unknownWords: [String]
}

enum SnapSource: String, Codable, CaseIterable {
    case photo
    case voice
    case typed
}
