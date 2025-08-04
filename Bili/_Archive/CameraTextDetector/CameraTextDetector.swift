import Foundation
import ComposableArchitecture
import SwiftUI
import Combine

struct CameraTextDetector: Reducer {
    
    struct State: Equatable {
        var detectedWords: Set<String>
    }
    
    enum Action: Equatable {
        case receivedNewPhoto(UIImage)
        case foundWords(Set<String>)
    }
    
    private enum CancelID {
        
    }
    
    @Dependency(\.textRecognitionClient) var textRecognitionClient
    @Dependency(\.languageRepository) var languageRepository
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .receivedNewPhoto(let photo):
                return .run { send in
                    let sourceLanguage = await languageRepository.fetchSourceLanguage()
                    let recognizedStrings = await textRecognitionClient.recognizeTextInImage(photo, sourceLanguage)
                    print(recognizedStrings)
                    // TODO include also position in the photo for each text and then use it to show detected rectangles
                    let words = extractWordsFromCapturedStringLines(recognizedStrings)
                    await send(.foundWords(words))
                }
            case .foundWords(let words):
                state.detectedWords = state.detectedWords.union(words)
            }
            return .none
        }
    }
}
