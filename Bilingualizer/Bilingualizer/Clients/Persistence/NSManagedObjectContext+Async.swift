/// Kudos to https://betterprogramming.pub/core-data-and-async-await-thread-safe-f96b6dbbb7c4
import CoreData
import App

@available(iOS 15.0.0, *)
extension NSManagedObjectContext {
    func get<E, R>(request: NSFetchRequest<E>) async throws -> [R] where E: NSManagedObject, E: ToSafeObject, R == E.SafeType {
        try await self.perform { [weak self] in
            try self?.fetch(request).compactMap { try $0.safeObject() } ?? []
        }
    }
}

enum SafeMapError: Error {
    case invalidMapping
}

protocol ToSafeObject {
    associatedtype SafeType
    func safeObject() throws -> SafeType
}
