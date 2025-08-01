/// TODO
/// - make it not depending on composable architecture, just do the translation shit here and return result
/// - just adhere to protocol declared for this client in App

import Foundation
import ComposableArchitecture
import MLKitTranslate
import App

// MARK: - Live API implementation
extension TranslationClient: DependencyKey {
    public static let liveValue = TranslationClient(
        translateIdentifiedText: { identifiedText, fromLanguage, toLanguage in
            
            let options = TranslatorOptions(sourceLanguage: fromLanguage.mkLanguage, targetLanguage: toLanguage.mkLanguage)
            let translator = Translator.translator(options: options)
            
            let conditions = ModelDownloadConditions(
                allowsCellularAccess: true,
                allowsBackgroundDownloading: true
            )
            
            let downloadedSuccessfully: Bool = await withCheckedContinuation { dictContinuation in
                translator.downloadModelIfNeeded(with: conditions) { error in
                    dictContinuation.resume(returning: error == nil)
                }
            }
            
            guard downloadedSuccessfully else {
                throw Errors.failedDownloadingTranslationModel
            }
            
            var translatedSentences: [ID: TranslatedText] = [:]
            for (id, originalText) in identifiedText {
                let translation: String? = await withCheckedContinuation { wordContinuation in
                    translator.translate(originalText) { translatedText, error in
                        guard error == nil, let translatedText = translatedText else {
                            wordContinuation.resume(returning: nil)
                            return
                        }
                        wordContinuation.resume(returning: translatedText)
                    }
                }
                translatedSentences[id] = translation ?? ""
            }
            
            return translatedSentences
        }
    )
}

private extension Language {
    var mkLanguage: TranslateLanguage {
        switch self {
        case .english:
            return .english
        case .german:
            return .german
        case .french:
            return .french
        case .italian:
            return .italian
        case .spanish:
            return .spanish
        case .czech:
            return .czech
        }
    }
}

private enum Errors: Error {
    case failedDownloadingTranslationModel
}
