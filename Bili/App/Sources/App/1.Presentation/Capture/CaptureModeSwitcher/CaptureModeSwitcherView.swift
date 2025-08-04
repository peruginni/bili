import Foundation
import ComposableArchitecture
import SwiftUI

struct CaptureModeSwitcherView: View {
    let store: StoreOf<CaptureModeSwitcher>
    let cameraModel: CameraClientObservableWrapper
    
    var isInputActive: FocusState<Bool>.Binding
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack {
                
                switch viewStore.mode {
                case .textInput, .speechInput:
                    TextInputView(
                        placeholder: "Write german text to translate...",
                        isFocused: isInputActive,
                        text: .init(
                            get: { viewStore.textInput },
                            set: { viewStore.send(.textInput(.setText($0))) }
                        )
                    )
                case .camera:
                    CameraModeView(
                        store: store.scope(state: \.camera, action: \.camera),
                        model: cameraModel
                    )
                case .none:
                    Text("")
                }
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                    
                        switch viewStore.mode {
                        case .textInput, .speechInput:
                            CircleButton(systemImage: "camera.fill", background: .black) {
                                viewStore.send(.setMode(.camera))
                            }
                        case .camera:
                            CircleButton(systemImage: "pencil", background: .white, foreground: .black) {
                                viewStore.send(.setMode(.textInput))
                            }
                        case .none:
                            Text("")
                        }
                        
                        
                        Spacer()
                        
                        if viewStore.mode == .textInput {
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
                }
            }
            .frame(height: CameraModeView.height)
            .padding()
            .background(.white)
            .clipShape(.rect(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
        }
    }
}

#Preview {
    VStack {
        Spacer()
        
        CaptureModeSwitcherView(
            store: Store(
                initialState: CaptureModeSwitcher.State(
                    mode: .textInput,
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
