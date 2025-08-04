import ComposableArchitecture
import SwiftUI

public struct Root {
    
    @MainActor public static func createCompositionRoot() -> AnyView {
        return AnyView(
            AppView()
        )
    }
}

