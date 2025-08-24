import Foundation
import AVFoundation
import UIKit

struct CameraPermissionService {
    var authorizationStatus: () -> AVAuthorizationStatus
    var requestAccess: (@escaping (Bool) -> Void) -> Void
    var openSystemSettings: () -> Void
}

extension DI {
    static var cameraPermissionService: CameraPermissionService = .live
}

extension CameraPermissionService {
    static let live = Self(
        authorizationStatus: { AVCaptureDevice.authorizationStatus(for: .video) },
        requestAccess: { handler in AVCaptureDevice.requestAccess(for: .video, completionHandler: handler) },
        openSystemSettings: {
            guard let url = URL(string: UIApplication.openSettingsURLString),
                  UIApplication.shared.canOpenURL(url) else { return }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    )
    static let mockAuthorized = Self(
        authorizationStatus: { .authorized },
        requestAccess: { handler in handler(true) },
        openSystemSettings: { }
    )
    static let mockNotDetermined = Self(
        authorizationStatus: { .notDetermined },
        requestAccess: { handler in handler(true) },
        openSystemSettings: { }
    )
    static let mockDenied = Self(
        authorizationStatus: { .denied },
        requestAccess: { handler in handler(true) },
        openSystemSettings: { }
    )
}
