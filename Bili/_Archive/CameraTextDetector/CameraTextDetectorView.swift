//
//  File.swift
//  
//
//  Created by Ondra on 18.05.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct CameraTextDetectorView: View {
    
    let store: StoreOf<CameraTextDetector>
    @ObservedObject var model: CameraDataModel
    
    init(store: StoreOf<CameraTextDetector>, model: CameraDataModel) {
        self.store = store
        self.model = model
    }
        
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Rectangle()
                .fill(Color.clear)
                .listRowBackground(
                    ViewfinderView(image: $model.viewfinderImage)
                        .task {
                            await model.start()
                        }
                        .onDisappear {
                            Task { @MainActor in
                                model.stop()
                            }
                        }
                        .onChange(of: model.viewfinderUIImage) { image in
                            viewStore.send(.receivedNewPhoto(image))
                        }
                )
                .frame(height: 200, alignment: .top)
        }
    }
}
