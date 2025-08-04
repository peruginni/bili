//
//  CameraClient.swift
//  App
//
//  Created by Ondra on 23.02.2025.
//


import Foundation
import ComposableArchitecture
import SwiftUI
import AVFoundation

// MARK: - CameraPermissionClient Protocol
struct CameraPermissionClient {
    var requestCameraPermission: @Sendable () async -> Bool
}

// MARK: - Live Implementation
extension CameraPermissionClient {
    static let live = CameraPermissionClient(
        requestCameraPermission: {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            if status == .notDetermined {
                return await AVCaptureDevice.requestAccess(for: .video)
            }
            return status == .authorized
        }
    )
}

// MARK: - Mock Implementation
extension CameraPermissionClient {
    static let mock = CameraPermissionClient(
        requestCameraPermission: {
            // Simulate granted permission
            return true
        }
    )
}

// MARK: - Dependency Registration
extension DependencyValues {
    var cameraPermissionClient: CameraPermissionClient {
        get { self[CameraPermissionClientKey.self] }
        set { self[CameraPermissionClientKey.self] = newValue }
    }
    
    private enum CameraPermissionClientKey: DependencyKey {
        static let liveValue = CameraPermissionClient.live
        static let testValue = CameraPermissionClient.mock
    }
}
