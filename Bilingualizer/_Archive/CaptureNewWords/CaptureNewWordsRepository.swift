import Foundation
import ComposableArchitecture
import NaturalLanguage
import Combine

actor CaptureNewWordsRepository {
    @Dependency(\.textRecognitionClient) var textRecognitionClient
    @Dependency(\.translationClient) var translationClient
    @Dependency(\.wordRepository) var wordRepository
    
    private let sourceLanguage: Language
    private let targetLanguage: Language
    
    private var queuedCapturedWords: Set<String> = []
    private var isRunning = false
    private var foundWords: Set<Word> = [] {
        didSet {
            foundWordsSubject.send(foundWords)
        }
    }
    private var processTask: Task<Void, Never>?
    
    private let foundWordsSubject = PassthroughSubject<Set<Word>, Never>()
    
    private var didUpdateFoundWords: AnyPublisher<Set<Word>, Never> {
        foundWordsSubject
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    public var didUpdateFoundWordsStream: AsyncStream<Set<Word>> {
        AsyncStream { continuation in
            let cancellable = self.didUpdateFoundWords.sink { continuation.yield($0) }
            continuation.onTermination = { continuation in
                cancellable.cancel()
            }
        }
    }
    
    public init(sourceLanguage: Language, targetLanguage: Language) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
    }
    
    public func enqueueCapturedWords(_ capturedWords: Set<String>) {
        queuedCapturedWords.formUnion(capturedWords)
        guard !isRunning else { return }
        isRunning = true
        let wordsToProcess = queuedCapturedWords
        queuedCapturedWords = []
        processTask = Task { await processWords(wordsToProcess: wordsToProcess) }
    }
    
    public func clearFoundWords() {
        foundWords = []
    }
    
    private func filterNounsAndVerbs(from words: [String]) -> [String] {
        var filteredWords = [String]()
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        for word in words {
            tagger.string = word
            let (tag, _) = tagger.tag(at: word.startIndex, unit: .word, scheme: .lexicalClass)
            if tag == .noun || tag == .verb {
                filteredWords.append(word)
            }
        }
        return filteredWords
    }
    
    private func fetchExistingWords(filteredWords: [String]) async -> ([Word], Set<String>) {
        let existingWords = await wordRepository.fetchWordsForLanguage(Set(filteredWords), sourceLanguage)
        let existingWordSet = Set(existingWords.map { $0.word.lowercased() })
        return (existingWords, existingWordSet)
    }
    
    private func storeNewWords(filteredWords: [String], existingWordSet: Set<String>) async {
        let newWords = filteredWords.filter { !existingWordSet.contains($0) }
        guard !newWords.isEmpty else { return }
        await wordRepository.storeWordsForLanguage(Set(newWords), sourceLanguage)
    }
    
    private func fetchUpdatedWords(filteredWords: [String]) async -> [Word] {
        return await wordRepository.fetchWordsForLanguage(Set(filteredWords), sourceLanguage)
    }
    
    private func findUntranslatedWords(words: [Word]) -> [(TranslationClient.ID, TranslationClient.SourceText)] {
        return words.filter { $0.translations[targetLanguage] == nil }
            .map { ($0.id, $0.word) }
    }
    
    private func requestTranslations(
        translationInputs: [(TranslationClient.ID, TranslationClient.SourceText)]
    ) async -> [WordRepository.StoreWordTranslation] {
        do {
            let translations = try await translationClient.translateIdentifiedText(translationInputs, sourceLanguage, targetLanguage)
            return translations.map { id, text in
                WordRepository.StoreWordTranslation(
                    wordID: id,
                    translationLanguage: targetLanguage,
                    translationText: text
                )
            }
        } catch {
            print("Translation failed: \(error)")
            return []
        }
    }
    
    private func storeTranslations(translations: [WordRepository.StoreWordTranslation]) async {
        guard !translations.isEmpty else { return }
        await wordRepository.storeWordTranslations(translations)
    }
    
    private func processWords(wordsToProcess: Set<String>) async {
        let lowerCasedWords = wordsToProcess.map { $0.lowercased() }
        let filteredWords = filterNounsAndVerbs(from: lowerCasedWords)
        
        // Step 2: Find words in the word repository
        let (existingWords, existingWordSet) = await fetchExistingWords(filteredWords: filteredWords)
        
        // Step 3: Store words that are not present
        await storeNewWords(filteredWords: filteredWords, existingWordSet: existingWordSet)
        
        // Step 4: Fetch and store updated words
        let updatedWords = await fetchUpdatedWords(filteredWords: filteredWords)
        foundWords.formUnion(updatedWords)
        
        // Step 5: Find words without translations
        let translationInputs = findUntranslatedWords(words: updatedWords)
        
        // Step 6: Request translations
        let storeTranslationsList = await requestTranslations(translationInputs: translationInputs)
        
        // Step 7: Store translations and update foundWords
        await storeTranslations(translations: storeTranslationsList)
        foundWords.formUnion(updatedWords)
        
        if !queuedCapturedWords.isEmpty {
            let nextBatch = queuedCapturedWords
            queuedCapturedWords = []
            await processWords(wordsToProcess: nextBatch)
        } else {
            isRunning = false
        }
    }
}
