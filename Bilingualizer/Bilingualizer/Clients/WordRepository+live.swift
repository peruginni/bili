import Foundation
import ComposableArchitecture
import App
import CoreData

extension WordRepository: DependencyKey {
    public static var liveValue: WordRepository {
        let persistence: PersistenceController = .shared
        return WordRepository(
            storeWordsForLanguage: { stringWords, sourceLanguage in
                let words = stringWords
                    .filter({ !$0.isEmpty })
                    .map {
                        Word(
                            word: $0,
                            sourceLanguage: sourceLanguage,
                            translations: [:],
                            createdAt: Date(),
                            updatedAt: Date(),
                            isArchived: false
                        )
                    }
                await persistence.saveNewWords(words)
            },
            storeWordTranslations: { wordTranslations in
                await persistence.storeWordTranslations(wordTranslations)
            },
            fetchWordsForLanguage: { stringWords, originalLanguage in
                let ids = stringWords.map { Word.makeIDFromWordAndLanguage($0, originalLanguage) }
                return await persistence.fetchByIDs(Set(ids))
            },
            fetchAllByLanguage: { language in
                return await persistence.fetchAllByLanguage(language)
            },
            archiveWord: { wordID in
                await persistence.archiveWord(id: wordID)
            },
            unarchiveWord: { wordID in
                await persistence.unarchiveWord(id: wordID)
            },
            deleteWord: { wordID in
                await persistence.deleteWord(id: wordID)
            }
        )
    }
}

private extension PersistenceController {

    func archiveWord(id: Word.ID) async {
        await backgroundContext.perform {
            if let persistedWord = fetchWords(context: backgroundContext, onlyIDs: [id]).first {
                persistedWord.isArchived = true
                saveBackgroundContext()
            }
        }
    }
    
    func unarchiveWord(id: Word.ID) async {
        await backgroundContext.perform {
            if let persistedWord = fetchWords(context: backgroundContext, onlyIDs: [id]).first {
                persistedWord.isArchived = false
                saveBackgroundContext()
            }
        }
    }
    
    func deleteWord(id: Word.ID) async {
        await backgroundContext.perform {
            if let persistedWord = fetchWords(context: backgroundContext, onlyIDs: [id]).first {
                backgroundContext.delete(persistedWord)
                saveBackgroundContext()
            }
        }
    }
    
    func storeWordTranslations(_ wordTranslations: [WordRepository.StoreWordTranslation]) async {
        await backgroundContext.perform {
            for wordTranslation in wordTranslations {
                if let persistedWord = fetchWords(context: backgroundContext, onlyIDs: [wordTranslation.wordID]).first {
                    var translations: [Language: String] = JsonHelper.decodeJsonDataToDict(persistedWord.translations)
                    translations[wordTranslation.translationLanguage] = wordTranslation.translationText
                    persistedWord.translations = JsonHelper.encodeDictToJsonData(translations)
                }
            }
            saveBackgroundContext()
        }
    }
    
    func fetchByIDs(_ ids: Set<Word.ID>) async -> [Word] {
        let words = await backgroundContext.perform {
            return fetchWords(
                context: backgroundContext,
                onlyIDs: ids
            )
            .compactMap { persistedWord -> Word? in
                return try? persistedWord.safeObject()
            }
        }
        return words
    }
    
    func fetchAllByLanguage(_ language: Language) async -> [Word] {
        let words = await backgroundContext.perform {
            return fetchWords(
                context: backgroundContext,
                sourceLanguage: language
            )
            .compactMap { persistedWord -> Word? in
                return try? persistedWord.safeObject()
            }
        }
        return words
    }
    
    func saveNewWords(_ words: [Word]) async {
        await backgroundContext.perform {
            for word in words {
                if var persistedWord = fetchWords(context: backgroundContext, onlyIDs: [word.id]).first {
                    persistedWord.updatedAt = Date()
                } else {
                    // TODO test long waitng here if it freeze app or not
                    let persistedWord = PersistedWord(context: backgroundContext)
                    persistedWord.id = word.id
                    persistedWord.word = word.word
                    persistedWord.sourceLanguage = word.sourceLanguage.rawValue
                    persistedWord.translations = JsonHelper.encodeDictToJsonData(word.translations)
                    persistedWord.createdAt = word.createdAt
                    persistedWord.updatedAt = word.updatedAt
                    persistedWord.isArchived = word.isArchived
                }
            }
            saveBackgroundContext()
        }
    }
    
    // MARK: - Helpers
    
    func fetchWords(
        context: NSManagedObjectContext,
        onlyIDs: Set<String>? = nil,
        sourceLanguage: Language? = nil,
        sort: WordRepository.Sort? = nil
    ) -> [PersistedWord] {
        let fetchRequest: NSFetchRequest<PersistedWord> = PersistedWord.fetchRequest()
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
                fetchRequest.sortDescriptors = [.init(key: "word", ascending: true)]
            case .titleDesc:
                fetchRequest.sortDescriptors = [.init(key: "word", ascending: false)]
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
}

extension PersistedWord: ToSafeObject {
    func safeObject() throws -> Word {
        guard
            let word = word,
            let sourceLanguageRaw = sourceLanguage,
            let sourceLanguage = Language(rawValue: sourceLanguageRaw),
            let createdAt = createdAt,
            let updatedAt = updatedAt
        else {
            throw SafeMapError.invalidMapping
        }
        
        return Word(
            word: word,
            sourceLanguage: sourceLanguage,
            translations: JsonHelper.decodeJsonDataToDict(translations),
            createdAt: createdAt,
            updatedAt: updatedAt,
            isArchived: isArchived
        )
    }
}
