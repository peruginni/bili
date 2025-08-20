import SwiftUI
import Dependencies
import ComposableArchitecture

struct SnapsView: View {
    @State private var viewModel = SnapsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.snapIDs, id: \.self) { id in
                            SnapItemView(
                                viewModel: SnapItemViewModel(
                                    id: id,
                                    onDelete: { viewModel.deleteSnap(id: id) }
                                )
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        CircleButton(systemImage: "plus", background: .accentColor, foreground: .white, borderColor: .accentColor.opacity(0.1)) {
                            viewModel.isInputActive = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Snaps")
            .sheet(isPresented: $viewModel.isInputActive) {
                CaptureModeSwitcherView(
                    store: Store(
                        initialState: CaptureModeSwitcher.State(
                            mode: .textInput,
                            textInput: "",
                            camera: CameraMode.State()
                        ),
                        reducer: {
                            CaptureModeSwitcher(
                                delegate: CaptureModeSwitcher.Delegate(
                                    didCaptureText: {
                                        viewModel.addSnap($0)
                                    },
                                    didCaptureImage: {
                                        viewModel.addSnap($0)
                                    }
                                )
                            )
                        }
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
                .presentationDetents([.height(CameraModeView.height - 50)])
                .presentationDragIndicator(.visible)
            }
        }
    }
}

#Preview {
    withDependencies {
        $0.cameraPermissionClient = CameraPermissionClient(
            requestCameraPermission: {
                // Simulate granted permission
                return true
            }
        )
    } operation: {
        DI.snapsRepository = MockSnapsRepository()
        return SnapsView()
    }
}
