import Foundation
import SwiftUI

struct SnapItemViewModel: Identifiable, Hashable {
    struct Loaded: Hashable {
        var text: String?
        var image: UIImage?
        let source: SnapSource
    }
    let id: UUID
    var loaded: Loaded?
}

struct SnapItemView: View {
    let viewModel: SnapItemViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let text = viewModel.loaded?.text {
                Text(text)
                    .font(.body)
            } else if let image = viewModel.loaded?.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 150)
            } else {
                Text("Fake translation for loading redacted purposes Fake translation sdfad asdf  adsfasdf")
                    .redacted(reason: .placeholder)
            }
            
            if let loaded = viewModel.loaded {
                Text("Source: \(loaded.source.rawValue.capitalized)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    SnapItemView(
        viewModel: SnapItemViewModel(
            id: UUID(),
            loaded: .init(
                text: "Hello, world!",
                image: nil,
                source: .typed
            )
        )
    )
}

#Preview("empty") {
    SnapItemView(
        viewModel: SnapItemViewModel(
            id: UUID(),
            loaded: nil
        )
    )
}
