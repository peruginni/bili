import ComposableArchitecture
import SwiftUI

public struct Root {
    @MainActor public static func createCompositionRoot() -> AnyView {
        let languageSelection = LanguageSelection(homeLanguage: .czech, foreignLanguage: .german)
        return AnyView(
            AppView(
                store: Store(
                    initialState: App.State(
                        languageSelection: languageSelection,
                        captureScreen: CaptureScreen.State(
                            languageSelection: languageSelection
                        )
                    )
                ) {
                    App()
                },
                cameraModel: CameraClientObservableWrapper(CameraClientLive())
            )
        )
    }
}

