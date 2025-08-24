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
                        
                        Spacer()
                    }
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
                CaptureView(
                    viewModel: CaptureViewModel(
                        delegate: .init(
                            onTextCaptured: viewModel.addSnap,
                            onPhotoCaptured: viewModel.addSnap
                        )
                    )
                )
                .presentationDetents([.height(CaptureView.totalHeight)])
                .presentationDragIndicator(.hidden)
            }
        }
    }
}

#Preview {
    DI.cameraModel = .mock
    DI.cameraPermissionService = .mockAuthorized
    DI.snapsRepository = MockSnapsRepository()
    return SnapsView()
}
