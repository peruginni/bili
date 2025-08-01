import SwiftUI
import ComposableArchitecture

struct CameraModeView: View {
    
    static let height = CameraClientConstant.captureHeight - 50
    
    let store: StoreOf<CameraMode>
    
    let model: CameraClientObservableWrapper
    
    init(store: StoreOf<CameraMode>, model: CameraClientObservableWrapper) {
        self.store = store
        self.model = model
    }
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            
            ZStack {
                if viewStore.cameraPermissionGranted {
                    CameraPreview(cameraModel: model)
                        .frame(height: Self.height)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .ignoresSafeArea()
                } else {
                    VStack {
                        Text("Camera access is required to take photos.")
                            .colorInvert()
                            .padding()
                    }
                }
            }
            .overlay(
                VStack {
                    HStack {
                        
                        Spacer()
                        
                        if viewStore.cameraPermissionGranted {
                            // Snap Photo Button
                            CircleButton(systemImage: "circle.fill", background: .white, foreground: .black, borderColor: .black.opacity(0.1)) {
                                model.capturePhoto { image in
                                    if let image = image {
                                        viewStore.send(.snapPhoto(image))
                                    }
                                }
                            }
                        } else {
                            Button(
                                action: {
                                    viewStore.send(.requestCameraPermission)
                                },
                                label: {
                                    Text("Grant Access")
                                        .frame(height: 24)
                                        .padding()
                                        .background(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .foregroundColor(.black)
                                }
                            )
                            .buttonStyle(.borderless)
                        }
                    }
                    
                    Spacer()
                }
                .padding() // Adds padding inside the image
            )

        }
        .ignoresSafeArea()
        .onAppear {
            store.send(.requestCameraPermission)
        }
    }
}
