import SwiftUI
import ComposableArchitecture

struct CaptureScreenView: View {
    let store: StoreOf<CaptureScreen>
    let cameraModel: CameraClientObservableWrapper

    @FocusState private var isInputActive: Bool
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(
                                store.scope(state: \.capturedItems, action: \.capturedItems)
                            ) { childStore in
                                CapturedItemView(store: childStore)
                            }
                        }
                        .padding()
                    }
                    .onTapGesture {
                        isInputActive = false
                    }
                }
                
                CaptureModeSwitcherView(
                    store: store.scope(
                        state: \.captureModeSwitcher,
                        action: \.captureModeSwitcher
                    ),
                    cameraModel: cameraModel,
                    isInputActive: $isInputActive
                )
            }
        }
    }

}


#Preview {
    CaptureScreenView(
        store: Store(
            initialState: .mock,
            reducer: { CaptureScreen() }
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

extension CaptureScreen.State {
    static var mock = Self(
        languageSelection: .mock,
        capturedItems: [
            .mock(text: "Hello"),
            .mock(text: "How are you?"),
        ]
    )
}
