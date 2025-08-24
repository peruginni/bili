import Foundation
import ComposableArchitecture
import SwiftUI
import AVFoundation

@Reducer
struct CameraMode {
    
    @ObservableState
    struct State: Equatable {
        var snappedPhotos: [UIImage] = []
        var cameraPermissionGranted: Bool = false
    }
    
    enum Action: Equatable {
        case snapPhoto(UIImage)
        case requestCameraPermission
        case cameraPermissionResponse(Bool)
        case cancel
    }
    
    @Dependency(\.cameraPermissionClient) var cameraPermissionClient
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .snapPhoto(image):
                state.snappedPhotos.append(image)
                return .none
                
            case .requestCameraPermission:
                return .run { send in
                    let granted = await cameraPermissionClient.requestCameraPermission()
                    await send(.cameraPermissionResponse(granted))
                }
                
            case let .cameraPermissionResponse(granted):
                state.cameraPermissionGranted = granted
                return .none
                
            case .cancel:
                return .none
            }
        }
    }
}
