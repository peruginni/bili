import SwiftUI
import Dependencies
import ComposableArchitecture

struct SnapsView: View {
    @State private var viewModel = SnapsViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                listOfSnaps
                addButton
            }
            .onAppear {
                viewModel.onAppear()
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
    
    @ViewBuilder
    private var listOfSnaps: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.snapIDs, id: \.self) { id in
                    SnapItemView(
                        viewModel: SnapItemViewModel(
                            id: id,
                            onDelete: viewModel.reload
                        )
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
            }
        }
    }
    
    @ViewBuilder
    private var addButton: some View {
        CircleButton(systemImage: "plus", background: .accentColor, foreground: .white, borderColor: .accentColor.opacity(0.1)) {
            viewModel.isInputActive = true
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .bottom)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

#Preview {
    DI.cameraModel = .mock
    DI.cameraPermissionService = .mockAuthorized
    let mock = MockSnapsRepository()
    DI.snapsRepository.mock(mock)
    return SnapsView()
}
