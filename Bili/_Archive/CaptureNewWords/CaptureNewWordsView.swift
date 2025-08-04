//
//  File.swift
//  
//
//  Created by Ondra on 18.05.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture
import Combine

struct CaptureNewWordsView: View {
    
    let store: StoreOf<CaptureNewWords>
    let cameraClient: CameraClientOld
        
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            List {
                
                CameraTextDetectorView(
                    store: store.scope(
                        state: \.cameraTextDetector,
                        action: \.cameraTextDetector
                    ),
                    model: .init(cameraClient: cameraClient)
                )
                
                
//                if viewStore.state.items.isEmpty {
//                    NoCapturedWordsYetView()
//                        .padding(20)
//                    
//                } 
                
                Section {
                    ForEach(store.scope(state: \.activeItems, action: \.items)) { store in
                        WordRowView(store: store)
                    }
                } header: {
                    HStack {
                        Text("Captured active words")
                        Spacer()
                    }
                }
                
                
//                Section(
//                    content: {
//                        ForEach(store.scope(state: \.archivedItems, action: \.items)) { store in
//                            WordRow(store: store)
//                        }
//                    },
//                    header: {
//                        HStack {
//                            Text("Captured archived words")
//                            Spacer()
//                        }
//                    }
//                )
            }
            .listStyle(.automatic)
            .edgesIgnoringSafeArea([.bottom])
            .navigationTitle("Capture words")
        }
    }
}

//#Preview {
//    NavigationView {
//        CaptureNewWordsView(
//            store: Store(
//                initialState: CaptureNewWords.State(
//                    sourceLanguage: .german,
//                    targetLanguage: .english
//                )
//            ) {
//                CaptureNewWords(
//                    captureNewWordsRepository: CaptureNewWordsRepository(
//                        sourceLanguage: .german,
//                        targetLanguage: .english
//                    )
//                )
//            },
//            cameraClient: CameraClientMock(
//                viewfinderImagePublisher: CurrentValueSubject<Image?, Never>(Image(systemName: "fleuron")).eraseToAnyPublisher()
//            )
//        )
//    }
//}
