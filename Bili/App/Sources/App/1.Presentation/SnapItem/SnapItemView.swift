import Foundation
import SwiftUI

struct SnapItemView: View {
    @State private var viewModel: SnapItemViewModel
    
    init(viewModel: SnapItemViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if let snap = viewModel.snap {
                VStack(alignment: .leading, spacing: 8) {
                    if let image = snap.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 150)
                    }
                    Text(snap.text ?? "")
                        .font(.body)
                    HStack {
                        Text("Source: \(snap.source.rawValue.capitalized)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Button("Delete", role: .destructive) {
                            viewModel.delete()
                        }
                        .font(.caption)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#Preview {
    DI.snapsRepository.mock(MockSnapsRepository())
    return SnapItemView(
        viewModel: SnapItemViewModel(
            id: MockSnapsRepository.snap1.id,
            onDelete: { }
        )
    )
}
