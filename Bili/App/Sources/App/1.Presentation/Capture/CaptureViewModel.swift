import Foundation
import UIKit
import AVFoundation

@MainActor
@Observable
final class CaptureViewModel {
    
    enum InputMode {
        case camera
        case text
    }
    
    // MARK: - Dependencies
    let cameraPermissionService = DI.cameraPermissionService
    
    struct Delegate {
        var onTextCaptured: ((String) -> Void)
        var onPhotoCaptured: ((UIImage) -> Void)
    }
    
    // MARK: - Published State
    var inputMode: InputMode = .camera
    var cameraPermissionGranted: Bool? = nil // nil = not determined
    var capturedText: String = ""
    var capturedImage: UIImage? = nil
    
    // MARK: - Callbacks
    var delegate: Delegate
    
    // MARK: - Init
    init(delegate: Delegate) {
        self.delegate = delegate
        checkCameraPermission()
    }
    
    // MARK: - Camera Permission
    func checkCameraPermission() {
        switch cameraPermissionService.authorizationStatus() {
        case .authorized:
            cameraPermissionGranted = true
        case .denied, .restricted:
            cameraPermissionGranted = false
        case .notDetermined:
            cameraPermissionGranted = nil
        @unknown default:
            cameraPermissionGranted = false
        }
    }
    
    func requestCameraPermission() {
        cameraPermissionService.requestAccess { [weak self] granted in
            Task { @MainActor in
                self?.cameraPermissionGranted = granted
            }
        }
    }
    
    func openSystemSettings() {
        cameraPermissionService.openSystemSettings()
    }
    
    // MARK: - Actions
    func switchToTextMode() {
        inputMode = .text
    }
    
    func switchToCameraMode() {
        inputMode = .camera
    }
    
    func confirmText() {
        let text = capturedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        delegate.onTextCaptured(text)
        capturedText = ""
    }
    
    func confirmPhoto(_ image: UIImage) {
        capturedImage = image
        delegate.onPhotoCaptured(image)
        capturedImage = nil
    }
}

// MARK: - Dependencies

extension CaptureViewModel.Delegate {
    static let mock: Self = Self(
        onTextCaptured: { _ in },
        onPhotoCaptured: { _ in }
    )
}
