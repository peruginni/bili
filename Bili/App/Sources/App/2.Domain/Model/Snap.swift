import Foundation
import UIKit

struct Snap: Identifiable, Equatable {
    enum Status {
        case captured
        case textDetected
        case translated
    }
    
    let id: UUID
    let text: String?
    let image: UIImage?
    let date: Date
    let source: SnapSource
    var unknownWords: [String]
}

enum SnapSource: String, Codable, CaseIterable {
    case photo
    case voice
    case typed
}
