////
////  File.swift
////  
////
////  Created by Ondra on 18.05.2023.
////
//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//struct SnapsView: View {
//    
//    let store: StoreOf<Snaps>
//    
//    var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            ZStack {
//                if viewStore.snaps.isEmpty {
//                 
//                    VStack(spacing: 10) {
//                        HStack(spacing: 5) {
//                            Image(systemName: "camera")
//                                .imageScale(.large)
//                            Image(systemName: "book")
//                                .imageScale(.large)
//                            Image(systemName: "person.text.rectangle")
//                                .imageScale(.large)
//                            Image(systemName: "newspaper")
//                                .imageScale(.large)
//                            Image(systemName: "doc.text")
//                                .imageScale(.large)
//                        }
//                        Text("You have no snaps yet")
//                            .font(.title3)
//                            .fontWeight(.bold)
//                        Text("Take picture of words you don't understand. I will help you learn those words! ✌️")
//                            .multilineTextAlignment(.center)
//                    }
//                    .padding(20)
//                    .offset(y: -60)
//                        
//                } else {
//                    ScrollView(.vertical) {
//                        SnapsGridView(
//                            items: viewStore.snaps,
//                            didTapItem: { viewStore.send(.showSnap($0.id)) }
//                        )
//                        .padding(.bottom, 120)
//                    }
//                }
//                
//                CTAButtonView(
//                    text: "Add new snaps",
//                    iconName: "plus",
//                    action: {
//                        viewStore.send(.addNewSnapTapped)
//                    }
//                )
//                .frame(maxHeight: .infinity, alignment: .bottom)
//                .padding(.bottom, 20)
//            }
//            .navigationTitle("Snaps")
//            .sheet(
//                store: self.store.scope(
//                    state: \.$addNewSnap,
//                    action: { .addNewSnap($0) }
//                ),
//                content: { store in
//                    SnapsAddNewView(store: store)
//                }
//            )
//            .task {
//                viewStore.send(.didLoad)
//            }
//            .onAppear() {
//                viewStore.send(.didAppear)
//            }
//            .onDisappear() {
//                viewStore.send(.didDisappear)
//            }
//        }
//    }
//}
//
//struct SnapsView_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SnapsView(
//                store: Store(
//                    initialState: Snaps.State(
//                        snaps: IdentifiedArrayOf(uniqueElements: items),
//                        addNewSnap: nil
//                    )
//                ) { Snaps() }
//            )
//        }
//    }
//}
//
//private let lipsumText = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam dapibus fermentum ipsum. Nam quis nulla. Nullam rhoncus aliquam metus. Nulla est. Aenean fermentum risus id tortor. Duis risus. Nullam dapibus fermentum ipsum. Fusce suscipit libero eget elit. Aenean vel massa quis mauris vehicula lacinia. Morbi leo mi, nonummy eget tristique non, rhoncus non leo"
//
//private let items: [Snaps.CellViewModel] = (1...50).map {
//    Snaps.CellViewModel(
//        id: UUID(),
//        title: "Test \($0)"
//    )
//}
