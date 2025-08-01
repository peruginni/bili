//import Foundation
//import ComposableArchitecture
//import SwiftUI
//
//struct SnapDetail: Reducer {
//    
//    struct State: Equatable {
//        enum Phase {
//            case isTranslating
//            case isRefreshingWords
//            case isRequestingDismiss
//            case idle
//        }
//        struct Sentence: Identifiable, Equatable {
//            let id: UUID
//            let words: [SnapDetailWordsView.Item]
//        }
//        var snap: Snap
//        var sentences: [Sentence] = []
//        var words: [Word.ID : Word] = [:]
//        var phase: Phase = .idle
//    
//        var wordInSentenceDetail: WordInSentenceDetail.State?
//        var isShowingWordInSentenceDetail = false
//    }
//    
//    enum Action: Equatable {
//        case translateIfNeeded
//        case startTranslatingWordsIntoTargetLanguage([Word], Language)
//        case refreshWords
//        case wordsRefreshed([Word.ID: Word], [State.Sentence])
//        case nameChanged(String)
//        case didCreateWordOnTap(Word, SnapDetailWordsView.Item, State.Sentence)
//        case wordInSentenceDetailTapped(SnapDetailWordsView.Item, State.Sentence)
//        case wordInSentenceDetailPreparedState(WordInSentenceDetail.State)
//        case wordInSentenceDetailAction(WordInSentenceDetail.Action)
//        case wordInSentenceDetailDismissed
//        case saveChangedName
//        case didTapRetake
//        case didTapAddMore
//        case didTapDelete
//        case dismiss
//    }
//    
//    @Dependency(\.translationClient) var translationClient
//    @Dependency(\.languageRepository) var languageRepository
//    @Dependency(\.snapRepository) var snapRepository
//    @Dependency(\.wordRepository) var wordRepository
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//            case .translateIfNeeded:
//                
//                state.phase = .isRefreshingWords
//                let stringWords = state.snap.words
//                let sourceLanguage = state.snap.language
//                
//                return .run { send in
//                    let words = await wordRepository.fetchWordsForLanguage(stringWords, sourceLanguage)
//                    let targetLanguage = await languageRepository.fetchTargetLanguage()
//                    let notTranslatedWords = words.filter({ $0.translations[targetLanguage] == nil })
//                    let shouldTranslate = !notTranslatedWords.isEmpty
//                    
//                    await send(
//                        shouldTranslate
//                        ? .startTranslatingWordsIntoTargetLanguage(notTranslatedWords, targetLanguage)
//                        : .refreshWords
//                    )
//                }
//                
//            case .startTranslatingWordsIntoTargetLanguage(let words, let targetLanguage):
//                
//                state.phase = .isTranslating
//                let sourceLanguage = state.snap.language
//                return .run { send in
//
//                    await translateSelectedWords(
//                        words: words.map { .init(wordID: $0.id, wordInSourceLanguage: $0.word) },
//                        sourceLanguage: sourceLanguage,
//                        targetLanguage: targetLanguage,
//                        translationClient,
//                        wordRepository
//                    )
//                    
//                    await send(.refreshWords)
//                }
//                
//            case .refreshWords:
//                
//                state.phase = .isRefreshingWords
//                let stringWords = state.snap.words
//                let sourceLanguage = state.snap.language
//                let sentences = state.snap.sentences
//                
//                return .run { send in
//                    let words = await wordRepository.fetchWordsForLanguage(stringWords, sourceLanguage)
//                    let wordsDict = words.reduce(into: [:], { partialResult, word in
//                        partialResult[word.id] = word
//                    })
//                    
//                    let targetLanguage = await languageRepository.fetchTargetLanguage()
//                    
//                    let sentences = makeSentencesViewModels(sentences, words: wordsDict, sourceLanguage: sourceLanguage, targetLanguage: targetLanguage)
//                    
//                    await send(.wordsRefreshed(wordsDict, sentences))
//                }
//                        
//            case .wordsRefreshed(let words, let sentences):
//            
//                state.phase = .idle
//                state.words = words
//                state.sentences = sentences
//                return .none
//                
//            case .nameChanged(let name):
//                state.snap.name = name
//                return .none
//                
//            case .saveChangedName:
//                let snap = state.snap
//                return .run { _ in 
//                    await snapRepository.store(snap)
//                }
//                
//            case .didCreateWordOnTap(let newWord, let newItem, let sentence):
//                
//                state.sentences = state.sentences.map {
//                    if $0.id == sentence.id {
//                        return .init(
//                            id: sentence.id,
//                            words: $0.words.map { item in
//                                if item.word == newItem.word {
//                                    return newItem
//                                } else {
//                                    return item
//                                }
//                            }
//                        )
//                    } else {
//                        return $0
//                    }
//                }
//                state.words[newWord.id] = newWord
//                
//                return .send(.wordInSentenceDetailTapped(newItem, sentence))
//                
//            case .wordInSentenceDetailTapped(let item, let sentence):
//                
//                return .run { [state] send in
//                    
//                    var words = state.words
//                    var item = item
//                    
//                    let sourceLanguage = await languageRepository.fetchSourceLanguage()
//                    let targetLanguage = await languageRepository.fetchTargetLanguage()
//                    
//                    guard let id = item.id else {
//                        let identifiableWord = makeWordIdentifiableText(item.word)
//                        await wordRepository.storeWordsForLanguage([identifiableWord], sourceLanguage)
//                        if let word = (await wordRepository.fetchWordsForLanguage([identifiableWord], sourceLanguage)).first {
//                            await translateSelectedWords(
//                                words: [.init(wordID: word.id, wordInSourceLanguage: word.word)],
//                                sourceLanguage: sourceLanguage,
//                                targetLanguage: targetLanguage,
//                                translationClient,
//                                wordRepository
//                            )
//                        }
//                        if let word = (await wordRepository.fetchWordsForLanguage([identifiableWord], sourceLanguage)).first {
//                            words[word.id] = word
//                            item = .init(
//                                id: word.id,
//                                word: item.word,
//                                above: word.isArchived ? nil : word.translations[targetLanguage]
//                            )
//                            await send(.didCreateWordOnTap(word, item, sentence))
//                        } else {
//                            await send(.wordInSentenceDetailDismissed)
//                        }
//                        return
//                    }
//                    
//                    guard let word = words[id] else {
//                        await send(.wordInSentenceDetailDismissed)
//                        return
//                    }
//                    
//                    let detailState = WordInSentenceDetail.State(
//                        sourceLanguage: word.sourceLanguage,
//                        targetLanguage: targetLanguage,
//                        word: word,
//                        originalSentence: .init(
//                            text: sentence.words.map { $0.word }.joined(separator: " "),
//                            language: word.sourceLanguage
//                        )
//                    )
//                    
//                    await send(.wordInSentenceDetailPreparedState(detailState))
//                }
//                
//            case .wordInSentenceDetailPreparedState(let detailState):
//                state.wordInSentenceDetail = detailState
//                state.isShowingWordInSentenceDetail = true
//                return .none
//                
//            case .wordInSentenceDetailAction(let action):
//                
//                switch action {
//                
//                case .load:
//                    return .none
//                case .didTranslateSentence:
//                    return .none
//                case .archive:
//                    return .none
//                case .unarchive:
//                    return .none
//                    
//                case .wordChanged:
//                    return .send(.refreshWords)
//                }
//                
//            case .wordInSentenceDetailDismissed:
//                
//                state.isShowingWordInSentenceDetail = false
//                return .none
//                
//            case .didTapRetake:
//                return .none
//                
//            case .didTapAddMore:
//                return .none
//                
//            case .didTapDelete:
//                let id = state.snap.id
//                return .run { send in
//                    await snapRepository.delete(id)
//                    await send(.dismiss)
//                }
//                
//            case .dismiss:
//                
//                state.phase = .isRequestingDismiss
//                return .none
//            }
//        }
//        /// LESSON LEARNED: I forgot to add following connection to reducer and then was surprised that in my WordInSentenceDetailView
//        /// when I use .task { viewStore.send(.load) } nothing happens. This was missing.
//        .ifLet(\.wordInSentenceDetail, action: /Action.wordInSentenceDetailAction) {
//            WordInSentenceDetail()
//        }
//    }
//}
//
//private func makeSentencesViewModels(.Sentence], words: [Word.ID: Word], sourceLanguage: Language, targetLanguage: Language) -> [SnapDetail.State.Sentence] {
//    return sentences.map { sentence in
//        SnapDetail.State.Sentence(
//            id: sentence.id,
//            words: sentence.text
//                .components(separatedBy: " ")
//                .map { wordText in
//                    let identifiableWordText = makeWordIdentifiableText(wordText)
//                    let wordID = Word.makeIDFromWordAndLanguage(identifiableWordText, sourceLanguage)
//                    guard let word = words[wordID] else {
//                        return SnapDetailWordsView.Item(
//                            id: nil,
//                            word: wordText,
//                            above: nil
//                        )
//                    }
//                    return SnapDetailWordsView.Item(
//                        id: word.id,
//                        word: wordText,
//                        above: word.isArchived ? nil : word.translations[targetLanguage]
//                    )
//                }
//        )
//    }
//}
