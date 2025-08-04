import SwiftUI
import Dependencies
import ComposableArchitecture

struct SnapsView: View {
    @State var viewModel = SnapsViewModel()
    @State private var isInputActive = false
    @State private var inputText = ""
    
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
                            isInputActive = true
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Snaps")
            .sheet(isPresented: $isInputActive) {
                VStack {
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
                .presentationDetents([.fraction(1/3)])
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
