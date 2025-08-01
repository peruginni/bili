import Foundation
import ComposableArchitecture
import SwiftUI
import Combine

struct LanguagePicker: Reducer {

    struct State: Equatable {
        enum Mode: Equatable {
            case sourceLanguage
            case targetLanguage
        }
        let mode: Mode
        var selectedLanguage: Language?
        var languages: [Language] = []
        var isLanguagePickerPresented: Bool
        var isChangingLanguage: Bool
    }
    
    enum Action: Equatable {
        case didLoad
        case loadSelectedLanguage
        case didLoadSelectedLanguage(source: Language, target: Language)
        case showLanguagePicker
        case languagePickerDismissed
        case didSelectLanguage(Language)
        case didFinishedChangingLanguage
        case didSendDuringChangeOfLanguage
    }
    
    @Dependency(\.languageRepository) var languageRepository
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadSelectedLanguage:
                return .run { send in
                    let source = await languageRepository.fetchSourceLanguage()
                    let target = await languageRepository.fetchTargetLanguage()
                    await send(.didLoadSelectedLanguage(source: source, target: target))
                }
                
            case .didLoad:
                return .merge(
                    .send(.loadSelectedLanguage),
                    .run { send in
                        for await _ in self.languageRepository.didChangeLanguageStream {
                            await send(.loadSelectedLanguage)
                        }
                    }
                )
                
            case .didLoadSelectedLanguage(let source, let target):
                state.selectedLanguage = state.mode == .sourceLanguage ? source : target
                state.languages = Language.allCases                
                return .none
                
            case .showLanguagePicker:
                state.isLanguagePickerPresented = true
                return .none
                
            case .languagePickerDismissed:
                state.isLanguagePickerPresented = false
                return .none
                
            case .didSelectLanguage(let language):
                state.isLanguagePickerPresented = false
                state.selectedLanguage = language
                state.isChangingLanguage = true
                let mode = state.mode
                return .run { send in
                    if mode == .sourceLanguage {
                        await languageRepository.setSourceLanguage(language)
                    } else {
                        await languageRepository.setTargetLanguage(language)
                    }
                    await send(.didFinishedChangingLanguage)
                }
                
            case .didFinishedChangingLanguage:
                state.isChangingLanguage = false
                return .none
                
            case .didSendDuringChangeOfLanguage:
                return .none
            }
        }
    }
}
