import Foundation
import Speech
import ComposableArchitecture

struct SpeechClient {
    var reset: () -> Void
    var sayTextInLanguage: (String, Language) async -> Void
}

extension SpeechClient: TestDependencyKey {
    static var testValue: SpeechClient = SpeechClient(
        reset: { },
        sayTextInLanguage: { _, _ in }
    )
    
    static var previewValue: SpeechClient = testValue
}

extension SpeechClient: DependencyKey {
    static var liveValue: SpeechClient {
        let impl = SpeechClientImpl()
        return SpeechClient(
            reset: {
                impl.reset()
            },
            sayTextInLanguage: { text, language in
                await impl.say(text, in: language)
            }
        )
    }
}

extension DependencyValues {
    var speechClient: SpeechClient {
        get { self[SpeechClient.self] }
        set { self[SpeechClient.self] = newValue }
    }
}

private class SpeechClientImpl: NSObject, AVSpeechSynthesizerDelegate {
    
    enum Voice {
        static let german = AVSpeechSynthesisVoice(language: "de-DE")
        static let english = AVSpeechSynthesisVoice(language: "en-US")
        static let czech = AVSpeechSynthesisVoice(language: "cs-CZ")
        static let french = AVSpeechSynthesisVoice(language: "fr-FR")
        static let spanish = AVSpeechSynthesisVoice(language: "es-ES")
        static let italian = AVSpeechSynthesisVoice(language: "it-IT")
    }
    
    struct CurrentRequest {
        var sayContinuation: CheckedContinuation<Void, any Error>
        var utterance: AVSpeechUtterance
    }
    
    var synthesizer: AVSpeechSynthesizer
    
    private var currentRequest: CurrentRequest?
    
    override init() {
        synthesizer = AVSpeechSynthesizer()
        super.init()
        synthesizer.delegate = self
    }
    
    func reset() {
        synthesizer.stopSpeaking(at: .immediate) // TODO: is it correct
        synthesizer = AVSpeechSynthesizer()
        synthesizer.delegate = self
    }
    
    func say(_ text: String, in language: Language) async {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = language.voice
        utterance.rate = 0.52
        
        try? await withTaskCancellationHandler(
            operation: { () -> Void in
                // Combined explanantions from here
                // https://forums.swift.org/t/how-to-cancel-a-publisher-when-using-withtaskcancellationhandler/49688/5
                // https://github.com/apple/swift-evolution/blob/main/proposals/0304-structured-concurrency.md#cancellation-handlers
                
                // This check is necessary in case this code runs after the task was
                // cancelled. In which case we want to bail right away.
                try Task.checkCancellation()
                
                return try await withCheckedThrowingContinuation { continuation -> Void in
                    guard !Task.isCancelled else {
                        continuation.resume(throwing: CancellationError())
                        return
                    }

                    currentRequest = CurrentRequest(
                        sayContinuation: continuation,
                        utterance: utterance
                    )
                    synthesizer.speak(utterance)
                }
            },
            onCancel: {
                synthesizer.stopSpeaking(at: .immediate)
                currentRequest?.sayContinuation.resume()
            }
        )
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        guard currentRequest?.utterance == utterance else { return }
        currentRequest?.sayContinuation.resume()
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        guard currentRequest?.utterance == utterance else { return }
        currentRequest?.sayContinuation.resume(throwing: CancellationError())
    }
}

private extension Language {
    var voice: AVSpeechSynthesisVoice? {
        switch self {
        case .english:
            return SpeechClientImpl.Voice.english
        case .german:
            return SpeechClientImpl.Voice.german
        case .french:
            return SpeechClientImpl.Voice.french
        case .italian:
            return SpeechClientImpl.Voice.italian
        case .spanish:
            return SpeechClientImpl.Voice.spanish
        case .czech:
            return SpeechClientImpl.Voice.czech
        }
    }
}
