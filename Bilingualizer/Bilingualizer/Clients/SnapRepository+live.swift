import Foundation
import ComposableArchitecture
import App
import CoreData

extension SnapRepository: DependencyKey {
    public static var liveValue: SnapRepository {
        let persistence = PersistenceController.shared
        let repository = SnapRepository(
            store: { snap in
                await persistence.saveNewSnap(snap)
            },
            fetch: { id in
                return await persistence.fetchByIDs([id]).first
            },
            fetchAllByLanguage: { language in
                return await persistence.fetchAllByLanguage(language)
            },
            delete: { id in
                await persistence.deleteSnapByID(id)
            },
            isEmpty: {
                return await persistence.isEmpty()
            }
        )
        #if TARGET_OS_SIMULATOR
        // TODO check if it really work. Wasn't showng error until I moved it out of defifs
        Task {
            if await repository.isEmpty() {
                await repository.store(.makeDummy(language: .german))
                await repository.store(.makeDummy(language: .german))
                await repository.store(.makeDummy(language: .german))
            }
        }
        #endif
        return repository
    }
}

private extension PersistenceController {
    
    func isEmpty() async -> Bool {
        let count = await backgroundContext.perform {
            return self.count(context: backgroundContext)
        }
        return count < 1
    }
        
    func fetchByIDs(_ ids: Set<Snap.ID>) async -> [Snap] {
        let snaps = await backgroundContext.perform {
            return fetchSnaps(
                context: backgroundContext,
                onlyIDs: ids
            )
            .compactMap { persistedSnap -> Snap? in
                return try? persistedSnap.safeObject()
            }
        }
        return snaps
    }
    
    func fetchAllByLanguage(_ language: Language) async -> [Snap] {
        let snaps = await backgroundContext.perform {
            return fetchSnaps(
                context: backgroundContext,
                sourceLanguage: language
            )
            .compactMap { persistedSnap -> Snap? in
                return try? persistedSnap.safeObject()
            }
        }
        return snaps
    }
    
    func deleteSnapByID(_ id: Snap.ID) async {
        await backgroundContext.perform {
            if let persistedSnap = fetchSnaps(context: backgroundContext, onlyIDs: [id]).first {
                backgroundContext.delete(persistedSnap)
                saveBackgroundContext()
            }
        }
    }
    
    func saveNewSnap(_ snap: Snap) async {
        await backgroundContext.perform {
            if let persistedSnap = fetchSnaps(
                context: backgroundContext,
                onlyIDs: [snap.id]
            ).first {
                persistedSnap.words = JsonHelper.encodeSnapWords(Array(snap.words))
                persistedSnap.updatedAt = Date()
            } else {
                // TODO test long waitng here if it freeze app or not
                let persistedSnap = PersistedSnap(context: backgroundContext)
                persistedSnap.id = snap.id
                persistedSnap.sourceLanguage = snap.language.rawValue
                persistedSnap.words = JsonHelper.encodeSnapWords(Array(snap.words))
                persistedSnap.createdAt = snap.createdAt
                persistedSnap.updatedAt = snap.updatedAt
            }
            saveBackgroundContext()
        }
    }
    
    // MARK: - Helpers
    
    func fetchSnaps(
        context: NSManagedObjectContext,
        onlyIDs: Set<UUID>? = nil,
        sourceLanguage: Language? = nil,
        sort: SnapRepository.Sort? = nil
    ) -> [PersistedSnap] {
        let fetchRequest: NSFetchRequest<PersistedSnap> = PersistedSnap.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        if let onlyIDs = onlyIDs {
            fetchRequest.predicate = NSPredicate(format:"id IN %@", onlyIDs)
        }
        if let sourceLanguage {
            fetchRequest.predicate = NSPredicate(format: "sourceLanguage == %@", sourceLanguage.rawValue)
        }
        if let sort {
            switch sort {
            case .titleAsc:
                fetchRequest.sortDescriptors = [.init(key: "name", ascending: true)]
            case .titleDesc:
                fetchRequest.sortDescriptors = [.init(key: "name", ascending: false)]
            case .createdAsc:
                fetchRequest.sortDescriptors = [.init(key: "createdAt", ascending: true)]
            case .createdDesc:
                fetchRequest.sortDescriptors = [.init(key: "createdAt", ascending: false)]
            }
        }
        
        do {
            return try context.fetch(fetchRequest)
        } catch let error as NSError {
            Log.debug("Unresolved error \(error), \(error.userInfo)")
            return []
        }
    }
    
    func count(
        context: NSManagedObjectContext
    ) -> Int {
        let fetchRequest: NSFetchRequest<PersistedSnap> = PersistedSnap.fetchRequest()
        fetchRequest.fetchBatchSize = 0
        do {
            return try context.count(for: fetchRequest)
        } catch let error as NSError {
            Log.debug("Unresolved error \(error), \(error.userInfo)")
            return 0
        }
    }
}

extension PersistedSnap: ToSafeObject {
    func safeObject() throws -> Snap {
        guard
            let id = id,
            let sourceLanguageRaw = sourceLanguage,
            let sourceLanguage = Language(rawValue: sourceLanguageRaw),
            let createdAt = createdAt,
            let updatedAt = updatedAt
        else {
            throw SafeMapError.invalidMapping
        }
        
        return Snap(
            id: id,
            language: sourceLanguage,
            words: Set(JsonHelper.decodeSnapWords(words)),
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
