import Foundation
import ComposableArchitecture
import Vision
import UIKit

struct TextRecognitionClient {
    var recognizeTextInImage: (UIImage, Language) async -> [String]
}

extension TextRecognitionClient: TestDependencyKey {
    static var testValue: TextRecognitionClient = TextRecognitionClient(
        recognizeTextInImage: { _, _ in
            return [
                "Test recognized text",
                "Another test recognized text"
            ]
        }
    )
    
    static var previewValue: TextRecognitionClient = testValue
}

extension TextRecognitionClient: DependencyKey {
    static var liveValue: TextRecognitionClient {
        
        return TextRecognitionClient(
            recognizeTextInImage: { image, language in
                // Get the CGImage on which to perform requests.
                guard let cgImage = image.cgImage else { return [] }
        
                // Create a new image-request handler.
                let requestHandler = VNImageRequestHandler(cgImage: cgImage)
        
                let recognizedStrings: [String] = await withCheckedContinuation { continuation in
                    // Create a new request to recognize text.
                    let request = VNRecognizeTextRequest { request, error in
        
                        guard let observations = request.results as? [VNRecognizedTextObservation] else {
                            continuation.resume(returning: [])
                            return
                        }
                        let recognizedStrings = observations.compactMap { observation in
                            // Return the string of the top VNRecognizedText instance.
                            return observation.topCandidates(1).first?.string
                        }
        
                        continuation.resume(returning: recognizedStrings)
                    }
                    request.recognitionLevel = .accurate
                    request.recognitionLanguages = [language.recognitionLanguageCode]
                    request.usesLanguageCorrection = true
        
                    do {
                        // Perform the text-recognition request.
                        try requestHandler.perform([request])
                    } catch {
//                        print("Unable to perform the requests: \(error).")
                        continuation.resume(returning: [])
                    }
                }
        
                return recognizedStrings
            }
        )
    }
}

extension DependencyValues {
    var textRecognitionClient: TextRecognitionClient {
        get { self[TextRecognitionClient.self] }
        set { self[TextRecognitionClient.self] = newValue }
    }
}
