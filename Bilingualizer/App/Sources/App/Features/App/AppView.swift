import Foundation
import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<App>
    let cameraModel: CameraClientObservableWrapper
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            CaptureScreenView(
                store: store.scope(
                    state: \.captureScreen,
                    action: \.captureScreen
                ),
                cameraModel: cameraModel
            )
        }
    }
}

#Preview {
    VStack {
        AppView(
            store: Store(
                initialState: App.State(
                    languageSelection: .mock,
                    captureScreen: .mock
                ),
                reducer: { App() }
            ) {
                $0.cameraPermissionClient = CameraPermissionClient(
                    requestCameraPermission: {
                        // Simulate granted permission
                        return true
                    }
                )
            },
            cameraModel: .mock
        )
    }
}
