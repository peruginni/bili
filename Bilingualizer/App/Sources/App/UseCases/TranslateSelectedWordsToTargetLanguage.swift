//
//  File.swift
//  
//
//  Created by Ondra on 10.06.2023.
//

import Foundation

struct TranslateSelectedWordsToTargetLanguageInputWord {
    let wordID: Word.ID
    let wordInSourceLanguage: String
}

func translateSelectedWords(
    words: [TranslateSelectedWordsToTargetLanguageInputWord],
    sourceLanguage: Language,
    targetLanguage: Language,
    _ translationClient: TranslationClient,
    _ wordRepository: WordRepository
) async -> Void {
    
    /// Translate
    let wordsToTranslate = words.map { ($0.wordInSourceLanguage, $0.wordInSourceLanguage) }
    let translatedWords = (try? await translationClient.translateIdentifiedText(wordsToTranslate, sourceLanguage, targetLanguage)) ?? [:]
    
    /// Store
    let wordTranslations: [WordRepository.StoreWordTranslation] = words
        .compactMap { word in
            guard let translation = translatedWords[word.wordInSourceLanguage] else { return nil }
            return .init(wordID: word.wordID, translationLanguage: targetLanguage, translationText: translation)
        }
    await wordRepository.storeWordTranslations(wordTranslations)
    
}
