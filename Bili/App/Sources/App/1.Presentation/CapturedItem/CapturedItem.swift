import UIKit
import ComposableArchitecture

@Reducer
struct CapturedItem {
    struct State: Equatable, Identifiable {
        enum Status: String, Equatable {
            case notProcessed = "Queued"
            case recognizingTextInImage = "Recognizing text in image..."
            case translating = "Translating..."
            case translated = "Translated"
        }
        let id: UUID
        let createdAt: Date
        var fromLanguage: Language
        var toLanguage: Language
        var status: Status
        var photo: UIImage?
        var text: String?
        var translation: String?
        
        init(
            id: UUID = UUID(),
            createdAt: Date = Date(),
            fromLanguage: Language,
            toLanguage: Language,
            status: Status = .notProcessed,
            photo: UIImage? = nil,
            text: String? = nil,
            translation: String? = nil
        ) {
            self.id = id
            self.createdAt = createdAt
            self.fromLanguage = fromLanguage
            self.toLanguage = toLanguage
            self.status = status
            self.photo = photo
            self.text = text
            self.translation = translation
        }
    }
    
    enum Action: Equatable {
        case startProcessing
        case startTextRecognition(UIImage)
        case finishedTextRecognition([String])
        case startTranslation(String)
        case finishedTranslation(String)
    }
    
    @Dependency(\.textRecognitionClient) var textRecognitionClient
    @Dependency(\.translationClient) var translationClient

    private enum CancelID {
        case recognizingTextInImage
        case translating
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .startProcessing:
                if let text = state.text {
                    return .send(.startTranslation(text))
                } else if let image = state.photo {
                    return .send(.startTextRecognition(image))
                }
                return .none
                
            case .startTextRecognition(let image):
                state.status = .recognizingTextInImage
                let language = state.toLanguage
                return .run { send in
                    let recognizedText = await textRecognitionClient.recognizeTextInImage(image, language)
                    try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds delay
                    await send(.finishedTextRecognition(recognizedText))
                }
                .cancellable(id: CancelID.recognizingTextInImage)
                
            case .finishedTextRecognition(let recognizedText):
                let joinedText = recognizedText.joined(separator: " ")
                state.text = joinedText
                return .send(.startTranslation(joinedText))
                
            case .startTranslation(let inputText):
                state.status = .translating
                let home = state.fromLanguage
                let foreign = state.toLanguage
                return .run { send in
                    // TODO expand to translate each also word individually
                    let translatedText = try? await translationClient.translateIdentifiedText([("id", inputText)], foreign, home)
                    await send(.finishedTranslation(translatedText?.first?.value ?? ""))
                }
                .cancellable(id: CancelID.recognizingTextInImage)
                
            case .finishedTranslation(let translatedText):
                state.status = .translated
                state.translation = translatedText
                return .none
            }
        }
    }
}
