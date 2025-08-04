import Foundation

func extractWordsFromCapturedStringLines(_ capturedStringLines: [String]) -> Set<String> {
    let sentences = extractSentencesFromCapturedStringLines(capturedStringLines)
//    let sentences = mergePartsIntoDeduplicatedSentences(partsWithSentences)
    let words = extractWordsFromString(sentences.joined(separator: " "))
    return words
}

func extractSentencesFromCapturedStringLines(_ capturedStringLines: [String]) -> [String] {
    var wholeText: String = ""
    for line in capturedStringLines {
        if wholeText.last == "-" {
            wholeText.removeLast()
            wholeText += line.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            wholeText += " "
            wholeText += line.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    let sentences: [String] = wholeText
        .components(separatedBy: ".")
        .map {
            $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
    return sentences
}

func mergePartsIntoDeduplicatedSentences(_ partsOfSentences: [[String]]) -> [String] {
    // TODO
    return partsOfSentences.flatMap { $0 }
}

func extractWordsFromString__oldWorkingVersion(_ input: String) -> Set<String> {
    let words = input
        .lowercased()
        .replacingOccurrences(of: "\\d", with: " ", options: .regularExpression) // remove numbers
        .replacingOccurrences(of: "[[:punct:]]", with: " ", options: .regularExpression) // remove punctation characters
        .split(separator: " ")
        .map {
            $0
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: .punctuationCharacters)
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    
    return Set(words)
}

func extractWordsFromString(_ input: String) -> Set<String> {
    let words = input
        .components(separatedBy: " ")
        .map(makeWordIdentifiableText)
    
    return Set(words)
}


func makeWordIdentifiableText(_ input: String) -> String {
    return input
        .lowercased()
        .replacingOccurrences(of: "\\d", with: " ", options: .regularExpression) // remove numbers
        .replacingOccurrences(of: "[[:punct:]]", with: " ", options: .regularExpression) // remove punctation characters
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .trimmingCharacters(in: .punctuationCharacters)
        .trimmingCharacters(in: .whitespacesAndNewlines)
        // TODO could be tweaked more to remove some nonsense words
}
