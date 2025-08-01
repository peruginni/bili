import Foundation
import ComposableArchitecture
import SwiftUI
import ConfettiSwiftUI

struct WordsView: View {
    let store: StoreOf<Words>
    
    @State private var confettiCounter: Int = 0
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
                
            List {
                
                Section {
                    ForEach(store.scope(state: \.filteredItems, action: \.items)) { store in
                        WordRowView(store: store)
                    }
                } header: {
                    Picker(
                        selection: Binding(
                            get: {
                                viewStore.filter
                            },
                            set: { value in
                                viewStore.send(.didSelectFilter(value))
                            }
                        ),
                        label: Text("Data Source")
                    ) {
                        ForEach(Words.State.Filter.allCases, id: \.self) { filter in
                            Text(filter.rawValue).tag(filter)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, -18)
                    .padding(.bottom, 10)
                }
                
            }
            .listStyle(.insetGrouped)
//            .confettiCannon(counter: $confettiCounter, num: 50, rainHeight: 20, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
            .navigationTitle("Words")
            .task {
                viewStore.send(.load)
            }
        }
    }
}

//struct WordsView_Previews: PreviewProvider {
//
//    static var previews: some View {
//        NavigationView {
//            WordsView(
//                store: Store(
//                    initialState: .init(
//                        mode: .unarchived,
//                        archivedItems: (1...10).map { Words.State.Item(id: UUID().uuidString, originalText: "From \($0)", translatedText: "To \($0)") },
//                        unarchivedItems: (1...10).map { Words.State.Item(id: UUID().uuidString, originalText: "From \($0)", translatedText: "To \($0)") }
//                    )
//                ) { Words() }
//            )
//        }
//    }
//}
