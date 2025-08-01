import Foundation
import XCTest
@testable import App

class TranslatedWordStorageLiveTests: XCTestCase {
    
    func test__save__addingModifiedWordWithSameID__willKeepLastChange() async {
        // Arrange:
        let storage = TranslatedWordStorage.makeLive()
        let a = TranslatedWordStorage.TranslatedWord(text: "hello", textLanguage: .english, lastUpdate: Date(), translations: [:], isArchived: false)
        await storage.save(a)
        
        // Act:
        let b = TranslatedWordStorage.TranslatedWord(text: "hello", textLanguage: .english, lastUpdate: Date(), translations: [.czech: "ahoj"], isArchived: false)
        await storage.save(b)
        
        // Assert:
        let allEnglish = await storage.getAllWordsForLanguage(.english)
        XCTAssertEqual(b, allEnglish[0])
    }
}
