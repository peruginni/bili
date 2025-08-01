import Foundation
import ComposableArchitecture
import SwiftUI
import ConfettiSwiftUI

struct WordRowView: View {
    let store: StoreOf<WordRow>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                
            HStack {
                Group {
                    Image(systemName: "speaker.wave.2.circle")
                    Text("\(viewStore.state.originalText) = \(viewStore.state.translatedText)")
                }
                .onTapGesture {
                    viewStore.send(.tapRow)
                }
                Spacer()
                if !viewStore.state.isArchived {
                    withAnimation {
                        Button("Archive") {
                            viewStore.send(.archive)
                        }
                    }
                } else {
                    Button("Unarchive") {
                        viewStore.send(.archive)
                    }
                }
            }
            .id(viewStore.state.id)
            .swipeActions(edge: .trailing) {
                Button(
                    role: .destructive,
                    action: {
                        viewStore.send(.delete)
                    },
                    label: {
                        Label("Delete", systemImage: "trash")
                    }
                )
            }
        }
    }
}

struct WordRowView_Previews: PreviewProvider {

    static var previews: some View {
        NavigationView {
            WordRowView(
                store: Store(
                    initialState: .init(
                        id: "id",
                        originalLanguage: .german,
                        originalText: "Apfel",
                        translatedText: "Apple",
                        isArchived: false
                    )
                ) { WordRow() }
            )
        }
    }
}
