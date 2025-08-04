import ComposableArchitecture
import SwiftUI
@testable import App

var exerciseView: AnyView {
  let view = ExerciseSessionView(
    store: Store(
        initialState: .init(
            sourceLanguage: .german,
            translationLanguage: .english,
            allWords: [
                ExerciseSession.State.WordViewModel(id: "1", source: "gast", translation: "guest")
            ]
        ),
        reducer: ExerciseSession()
    )
  )
  return AnyView(view)
}
