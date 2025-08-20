import SwiftUI
import ComposableArchitecture

struct CameraModeView: View {
    
    static let height = CameraClientConstant.captureHeight
    
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
            .onTapGesture {
                guard viewStore.cameraPermissionGranted else { return }
                snapPhoto(viewStore: viewStore)
            }
            .overlay(
                VStack {
                    Spacer()
                    
                    HStack {
                        
                        Spacer()
                        
                        if viewStore.cameraPermissionGranted {
                            // Snap Photo Button
                            CircleButton(systemImage: "circle.fill", background: .white, foreground: .black, borderColor: .black.opacity(0.1)) {
                                snapPhoto(viewStore: viewStore)
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
                    .ignoresSafeArea(.all)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .ignoresSafeArea(.all)
            )

        }
        .ignoresSafeArea()
        .onAppear {
            store.send(.requestCameraPermission)
        }
    }
    
    func snapPhoto(viewStore: ViewStore<CameraMode.State, CameraMode.Action>) {
        model.capturePhoto { image in
            if let image = image {
                viewStore.send(.snapPhoto(image))
            }
        }
    }
}
