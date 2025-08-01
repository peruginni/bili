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
//struct SnapWordView: View {
//    
//    let store: StoreOf<SnapWord>
//    
//    var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//
//            VStack(spacing: 10) {
//                HStack(spacing: 5) {
//                    Image(systemName: "camera")
//                        .imageScale(.large)
//                    Image(systemName: "book")
//                        .imageScale(.large)
//                    Image(systemName: "person.text.rectangle")
//                        .imageScale(.large)
//                    Image(systemName: "newspaper")
//                        .imageScale(.large)
//                    Image(systemName: "doc.text")
//                        .imageScale(.large)
//                }
//                Text("You have no snaps yet")
//                    .font(.title3)
//                    .fontWeight(.bold)
//                Text("Take picture of words you don't understand. I will help you learn those words! ✌️")
//                    .multilineTextAlignment(.center)
//            }
//            .padding(20)
//            .offset(y: -60)
//            .navigationTitle("Snap unknown words")
//        }
//    }
//}
//
//struct SnapWordView_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SnapWordView(
//                store: Store(
//                    initialState: SnapWord.State()
//                ) { SnapWord() }
//            )
//        }
//    }
//}
