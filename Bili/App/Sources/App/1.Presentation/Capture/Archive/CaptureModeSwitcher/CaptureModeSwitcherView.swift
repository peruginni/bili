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
                Color.white.ignoresSafeArea()
                
                switch viewStore.mode {
                case .textInput, .speechInput:
                    VStack {
                        TextInputView(
                            placeholder: "Write german text to translate...",
                            isFocused: isInputActive,
                            text: .init(
                                get: { viewStore.textInput },
                                set: { viewStore.send(.textInput(.setText($0))) }
                            )
                        )
                        .padding()
                        Spacer()
                    }
                    .padding(.top, 20)
                case .camera:
                    VStack {
                        CameraModeView(
                            store: store.scope(state: \.camera, action: \.camera),
                            model: cameraModel
                        )
                        Spacer()
                    }
                case .none:
                    Text("")
                }
                
                VStack {
                    
                    Spacer()
                    
                    HStack {
                    
                        switch viewStore.mode {
                        case .textInput:
                            CircleButton(systemImage: "camera.fill", background: .black) {
                                viewStore.send(.setMode(.camera))
                            }
                            CircleButton(systemImage: "microphone.fill", background: .white, foreground: .black, borderColor: .black) {
                                viewStore.send(.setMode(.speechInput))
                            }
                        case .speechInput:
                            CircleButton(systemImage: "camera.fill", background: .black) {
                                viewStore.send(.setMode(.camera))
                            }
                            CircleButton(systemImage: "stop.fill", background: .white, foreground: .black, borderColor: .black) {
                                viewStore.send(.setMode(.textInput))
                            }
                            Text("Recording...")
                        case .camera:
                            CircleButton(systemImage: "pencil", background: .white, foreground: .black) {
                                viewStore.send(.setMode(.textInput))
                            }
                            CircleButton(systemImage: "microphone.fill", background: .white, foreground: .black, borderColor: .black) {
                                viewStore.send(.setMode(.speechInput))
                            }
                        case .none:
                            Text("")
                        }
                        
                        
                        Spacer()
                        
                        if viewStore.mode == .textInput || viewStore.mode == .speechInput {
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
                    // .ignoresSafeArea(.all)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                //.ignoresSafeArea(.all)
                
            }
            // .ignoresSafeArea(.all)
            .frame(height: CameraModeView.height)
            // .clipShape(.rect(topLeadingRadius: 30, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 30, style: .continuous))
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
                reducer: { CaptureModeSwitcher(delegate: nil) }
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
