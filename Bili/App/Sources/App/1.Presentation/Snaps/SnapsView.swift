import SwiftUI
import SwiftUI

struct SnapsView: View {
    @State var viewModel = SnapsViewModel()
    
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
                                
                            }
                            .padding()
                    }
                }
            }
            .navigationTitle("Snaps")
        }
    }
}

#Preview {
    DI.snapsRepository = MockSnapsRepository()
    return SnapsView()
}
