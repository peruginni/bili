import Foundation
import AVFoundation
import UIKit


@MainActor
protocol CameraClient {
    func startSession()
    func stopSession()
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer
    func capturePhoto(completion: @escaping (UIImage?) -> Void)
}

enum CameraClientConstant {
    static let captureHeight: CGFloat = 300
}

@MainActor
class CameraClientObservableWrapper: ObservableObject {
    let client: any CameraClient
    
    init(_ client: any CameraClient) {
        self.client = client
    }
    func startSession() {
        client.startSession()
    }
    
    func stopSession() {
        client.stopSession()
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return client.getPreviewLayer()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        client.capturePhoto(completion: completion)
    }
}

@MainActor
class CameraClientLive: NSObject, CameraClient, ObservableObject, @preconcurrency AVCapturePhotoCaptureDelegate {
        
    private let session = AVCaptureSession()
    private let output = AVCapturePhotoOutput()
    private let previewLayer = AVCaptureVideoPreviewLayer()
    private var captureCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        session.sessionPreset = .photo
        
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }
        
        if session.canAddInput(input) { session.addInput(input) }
        if session.canAddOutput(output) { session.addOutput(output) }
        
        previewLayer.session = session
        previewLayer.videoGravity = .resizeAspectFill
        
        DispatchQueue.main.async {
            self.adjustPreviewFrame()
        }
    }
    
    private func adjustPreviewFrame() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first
        else { return }
        
        let screenWidth = window.bounds.width
        let cropHeight: CGFloat = CameraClientConstant.captureHeight // screenWidth * (9.0 / 16.0) // Keep 16:9 ratio
        
        let cropY: CGFloat = 0 // (window.bounds.height - cropHeight) / 2 // Center vertically
        
        // Update the preview layer
        previewLayer.frame = CGRect(x: 0, y: cropY, width: screenWidth, height: cropHeight)
        previewLayer.videoGravity = .resizeAspectFill
    }
    
    func startSession() {
        Task.detached(priority: .background) { [weak self] in
            guard let self else { return }
            let isRunning = await session.isRunning
            guard !isRunning else { return }
            await session.startRunning()
        }
    }
    
    func stopSession() {
        Task { @MainActor in
            guard session.isRunning else { return }
            session.stopRunning()
        }
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return previewLayer
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        self.captureCompletion = completion
        output.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let originalImage = UIImage(data: data) else {
            captureCompletion?(nil)
            return
        }
        
        // Crop the image to 320x180
        let croppedImage = cropImageToCenter(originalImage)
        
        // Return the cropped image
        captureCompletion?(croppedImage)
    }
    
    private func cropImageToCenter(_ image: UIImage) -> UIImage? {
        let screenWidth = UIScreen.main.bounds.width
        let targetHeight: CGFloat = CameraClientConstant.captureHeight
        let targetRatio = screenWidth / targetHeight  // Aspect ratio based on screen width and fixed height
        
        guard let cgImage = image.cgImage else { return nil }
        
        // Ensure image is oriented correctly
        let fixedImage = fixOrientation(image)
        
        let originalWidth = CGFloat(fixedImage.size.width)
        let originalHeight = CGFloat(fixedImage.size.height)
        let originalRatio = originalWidth / originalHeight
        
        var cropWidth = originalWidth
        var cropHeight = originalHeight
        
        if originalRatio > targetRatio {
            // Image is too wide → crop width
            cropWidth = originalHeight * targetRatio
        } else {
            // Image is too tall → crop height
            cropHeight = originalWidth / targetRatio
        }
        
        let cropX = (originalWidth - cropWidth) / 2
        let cropY = (originalHeight - cropHeight) / 2
        let cropRect = CGRect(x: cropX, y: cropY, width: cropWidth, height: cropHeight)
        
        guard let croppedCGImage = fixedImage.cgImage?.cropping(to: cropRect) else { return nil }
        
        return UIImage(cgImage: croppedCGImage, scale: fixedImage.scale, orientation: fixedImage.imageOrientation)
    }
    
    private func fixOrientation(_ image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image // Already correct
        }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return fixedImage ?? image
    }

}

class CameraClientMock: NSObject, CameraClient {
        
    func startSession() {
        
    }
    
    func stopSession() {
        
    }
    
    func getPreviewLayer() -> AVCaptureVideoPreviewLayer {
        return .init()
    }
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let dummyImage = UIImage(systemName: "camera.fill")!
        completion(dummyImage)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?) {
        
    }
}

extension CameraClientObservableWrapper {
    static var mock = CameraClientObservableWrapper(CameraClientMock())
}
