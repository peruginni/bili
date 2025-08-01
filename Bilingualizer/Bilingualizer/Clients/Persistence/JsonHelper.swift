import Foundation
import App

enum JsonHelper {
    static let jsonEncoder = JSONEncoder()
    static let jsonDecoder = JSONDecoder()
    
    static func encodeDictToJsonData(_ dictionary: [Language: String]) -> Data? {
        return try? JsonHelper.jsonEncoder.encode(dictionary)
    }
    
    static func decodeJsonDataToDict(_ jsonData: Data?) -> [Language: String] {
        guard let jsonData else { return [:] }
        return (try? JsonHelper.jsonDecoder.decode([Language: String].self, from: jsonData)) ?? [:]
    }
    
//    static func encodeRawCapturedParts(_ rawParts: [Snap.RawCapturedPart]) -> Data? {
//        return try? JsonHelper.jsonEncoder.encode(rawParts)
//    }
//    
//    static func decodeRawCapturedParts(_ jsonData: Data?) -> [Snap.RawCapturedPart] {
//        guard let jsonData else { return [] }
//        return (try? JsonHelper.jsonDecoder.decode([Snap.RawCapturedPart].self, from: jsonData)) ?? []
//    }
//    
//    static func encodeSnapSentences(_ rawParts: [Snap.Sentence]) -> Data? {
//        return try? JsonHelper.jsonEncoder.encode(rawParts)
//    }
//    
//    static func decodeSnapSentences(_ jsonData: Data?) -> [Snap.Sentence] {
//        guard let jsonData else { return [] }
//        return (try? JsonHelper.jsonDecoder.decode([Snap.Sentence].self, from: jsonData)) ?? []
//    }
    
    static func encodeSnapWords(_ rawParts: [String]) -> Data? {
        return try? JsonHelper.jsonEncoder.encode(rawParts)
    }
    
    static func decodeSnapWords(_ jsonData: Data?) -> [String] {
        guard let jsonData else { return [] }
        return (try? JsonHelper.jsonDecoder.decode([String].self, from: jsonData)) ?? []
    }
    
    
}
