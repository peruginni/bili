import SwiftUI
import Dependencies
import ComposableArchitecture

struct SnapsView: View {
    @State private var viewModel = SnapsViewModel()
    
    var body: some View {
        ZStack {
            listOfSnaps
            addButton
        }
        .onAppear {
            viewModel.reload()
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
    
    @ViewBuilder
    private var listOfSnaps: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.snaps, id: \.self) { snap in
                    SnapItemView(viewModel: snap)
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
