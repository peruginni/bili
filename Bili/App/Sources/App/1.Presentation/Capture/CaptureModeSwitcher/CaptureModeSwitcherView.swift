import Foundation
import ComposableArchitecture
import SwiftUI

struct CaptureModeSwitcherView: View {
    let store: StoreOf<CaptureModeSwitcher>
    let cameraModel: CameraClientObservableWrapper
    
    var isInputActive: FocusState<Bool>.Binding
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                
                TextInputView(
                    placeholder: "Write german text to translate...",
                    isFocused: isInputActive,
                    text: .init(
                        get: { viewStore.textInput },
                        set: { viewStore.send(.textInput(.setText($0))) }
                    )
                )
                
                HStack {
                    
                    CircleButton(systemImage: "camera.fill", background: .black) {
                        viewStore.send(.setCameraSheetPresented(true))
                    }
                    
                    Spacer()

                    CircleButton(
                        systemImage: "arrow.up",
                        background: viewStore.textInput.isEmpty ? .black.opacity(0.2) : .black,
                        foreground: .white,
                        borderColor: viewStore.textInput.isEmpty ? .clear : .black.opacity(0.1)
                    ) {
                        viewStore.send(.textInput(.confirm), animation: .spring)
                    }
                    .disabled(viewStore.textInput.isEmpty)
                }
            
            }
            .padding()
            .background(.white)
            .clipShape(.rect(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
            .sheet(isPresented: viewStore.binding(
                get: { $0.isCameraSheetPresented },
                send: CaptureModeSwitcher.Action.setCameraSheetPresented
            )) {
                CameraModeView(
                    store: store.scope(state: \.camera, action: \.camera),
                    model: cameraModel
                )
                .presentationDetents([.height(CameraModeView.height)])
            }
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        CaptureModeSwitcherView(
            store: Store(
                initialState: CaptureModeSwitcher.State(
                    mode: .none,
                    textInput: "",
                    camera: CameraMode.State()
                ),
                reducer: { CaptureModeSwitcher() }
            ) {
                $0.cameraPermissionClient = CameraPermissionClient(
                    requestCameraPermission: {
                        // Simulate granted permission
                        return true
                    }
                )
            },
            cameraModel: .mock,
            isInputActive: FocusState<Bool>().projectedValue
        )
    }
}
