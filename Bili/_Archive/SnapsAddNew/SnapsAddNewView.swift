//import Foundation
//import ComposableArchitecture
//import SwiftUI
//
//struct SnapsAddNewView: View {
//    
//    let store: StoreOf<SnapsAddNew>
//
//    @Environment(\.colorScheme) var colorScheme
//    
//    private static let barHeightFactor = 0.15
//    @StateObject var model = CameraDataModel()
//    
//    var body: some View {
//        WithViewStore(self.store, observe: { $0 }) { viewStore in
//            Group {
//                switch viewStore.state.phase {
//                case .takingPhoto:
//                    TakingPhotoView(
//                        viewfinderImage: $model.viewfinderImage,
//                        takePhoto: { model.camera.takePhoto() },
//                        isInProgress: false,
//                        showButton: true
//                    )
//                    .task {
//                        await model.camera.start()
////                        await model.loadPhotos()
////                        await model.loadThumbnail()
//                    }
//                    .onDisappear {
//                        Task { @MainActor in
//                            model.camera.stop()
//                        }
//                    }
//                    .navigationTitle("Take Photo of Text")
//                    
//                case .recognizingTextInImage(let image):
//                    TakingPhotoView(
//                        viewfinderImage: .constant(Image(uiImage: image)),
//                        takePhoto: { /* no action */ },
//                        isInProgress: true,
//                        showButton: true
//                    )
//                    .navigationTitle("Recognizing text")
//                    
//                case .showingSnap, .requestingDismiss:
//                    IfLetStore(self.store.scope(state: \.snapDetail, action: SnapsAddNew.Action.snapDetail)) { substore in
//                        SnapDetailView(store: substore)
//                    }
////                    RecognizedTextView(
////                        store: store,
////                        retake: {
////                            model.lastSnappedImage = nil
////                            viewStore.send(.retakeLastOne)
////                        },
////                        addMore: {
////                            model.lastSnappedImage = nil
////                            viewStore.send(.addMore)
////                        },
////                        close: {
////                            model.lastSnappedImage = nil
////                            viewStore.send(.dismiss)
////                        }
////                    )
////                    .navigationTitle("Saved snap")
//                }
//            }
//            .onChange(of: model.lastSnappedUIImage, perform: { image in
//                if let image = image {
//                    viewStore.send(.recognizeTextInPhoto(image))
//                } else {
//                    // viewStore.send(.startTakingPhoto)
//                }
//            })
//        }
//    }
//}
//
//struct SnapsAddNewView_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            SnapsAddNewView(
//                store: Store(
//                    initialState: SnapsAddNew.State(
//                        snap: Snap(
//                            id: UUID(),
//                            language: .english,
//                            words: [],
//                            createdAt: Date(),
//                            updatedAt: Date()
//                        ),
//                        phase: .takingPhoto
//                    )
//                ) { SnapsAddNew() }
//            )
//        }
//        
//        NavigationView {
//            SnapsAddNewView(
//                store: Store(
//                    initialState: SnapsAddNew.State(
//                        snap: Snap(
//                            id: UUID(),
//                            language: .english,
//                            words: [],
//                            createdAt: Date(),
//                            updatedAt: Date()
//                        ),
//                        phase: .recognizingTextInImage(UIImage(systemName: "people")!)
//                    )
//                ) { SnapsAddNew() }
//            )
//        }
//
//    }
//}
