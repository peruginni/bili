import ComposableArchitecture
import SwiftUI
@testable import App

var exerciseSessionView: AnyView {
    let view = ExerciseSessionView(
        store: Store(
            initialState: .init(
                sourceLanguage: .german,
                translationLanguage: .english,
                allWords: [],
                pastWords: Array(
                    (1...3).map { _ in
                        ExerciseSession.State.WordViewModel(id: UUID().uuidString, source: "gast", translation: "guest")
                    }
                ),
                currentWord: ExerciseSession.State.WordViewModel(
                    id: UUID().uuidString,
                    source: "spaziergang",
                    translation: "walk"
                ),
                nextWords: Array(
                    (1...10).map { _ in
                        ExerciseSession.State.WordViewModel(id: UUID().uuidString, source: "gast", translation: "guest")
                    }
                )
            ),
            reducer: EmptyReducer()
        )
    )
    return AnyView(view)
}
