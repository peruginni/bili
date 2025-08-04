import ComposableArchitecture
import SwiftUI

@MainActor
public enum DI {
    
    static var userDefaultsRepository: UserDefaultsRepository = UserDefaultsRepositoryImpl()

    static var snapsRepository: SnapsRepository = InMemorySnapsRepository()
    
    static var cameraModel: CameraClientObservableWrapper = CameraClientObservableWrapper(CameraClientLive())
}

