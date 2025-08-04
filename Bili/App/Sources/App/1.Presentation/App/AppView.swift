import Foundation
import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

struct AppView: View {
    var body: some View {
        NavigationStack {
            SnapsView()
        }
    }
}

#Preview {
    withDependencies {
        $0.cameraPermissionClient = CameraPermissionClient(
            requestCameraPermission: {
                // Simulate granted permission
                return true
            }
        )
    } operation: {
        AppView()
    }
}
