/*
See the License.txt file for this sample’s licensing information.
*/

import AVFoundation
import SwiftUI
import os.log
import Combine

@MainActor
final class CameraDataModel: ObservableObject {
    
    @Published var viewfinderImage: Image?
    @Published var viewfinderUIImage: UIImage = UIImage()
    
    private let cameraClient: CameraClientOld
    private var cancellableImage: AnyCancellable?
    private var cancellableUIImage: AnyCancellable?
    
    init(cameraClient: CameraClientOld) {
        self.cameraClient = cameraClient
        cancellableImage = cameraClient.viewfinderImagePublisher
            .sink { [weak self] image in
                Task { @MainActor in
                    self?.viewfinderImage = image
                }
            }
        cancellableUIImage = cameraClient.viewfinderUIImagePublisher
            .throttle(for: .seconds(2), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] image in
                Task { @MainActor in
                    self?.viewfinderUIImage = image ?? UIImage()
                }
            }
    }
    
    func start() async {
        print("CameraDataModel.start")
        await cameraClient.start()
    }
    
    func stop() {
        print("CameraDataModel.stop")
        cameraClient.stop()
    }
    
}

@MainActor
protocol CameraClientOld {
    var viewfinderImagePublisher: AnyPublisher<Image?, Never> { get }
    var viewfinderUIImagePublisher: AnyPublisher<UIImage?, Never> { get }
    func start() async
    func stop()
}

struct CameraClientOldMock: CameraClientOld {
    var viewfinderImagePublisher: AnyPublisher<Image?, Never>
    var viewfinderUIImagePublisher: AnyPublisher<UIImage?, Never>
    func start() async { }
    func stop() { }
}

final class CameraClientOldLive: CameraClientOld {
    let camera = Camera()
    let photoCollection = PhotoCollection(smartAlbum: .smartAlbumUserLibrary)
    
    @Published var viewfinderImage: Image?
    var viewfinderImagePublisher: AnyPublisher<Image?, Never> { $viewfinderImage.eraseToAnyPublisher() }
    @Published var thumbnailImage: Image?
    @Published var lastSnappedImage: Image?
    @Published var lastSnappedUIImage: UIImage?
    var viewfinderUIImagePublisher: AnyPublisher<UIImage?, Never> { $lastSnappedUIImage.eraseToAnyPublisher() }
    
    var isPhotosLoaded = false
    
    init() {
        Task {
            await handleCameraPreviews()
        }
        
        Task {
            await handleCameraPhotos()
        }
    }
    
    deinit {
        camera.stop()
    }
    
    func start() async {
        await camera.start()
    }
    
    func stop() {
        camera.stop()
    }
    
    func handleCameraPreviews() async {
        let imageStream = camera.previewStream
            .map { ($0, $0.image) }

        for await (ciImage, image) in imageStream {
            Task { @MainActor in
                viewfinderImage = image
                lastSnappedUIImage = UIImage(ciImage: ciImage)
            }
        }
    }
    
    func handleCameraPhotos() async {
        let unpackedPhotoStream = camera.photoStream
            .compactMap { await self.unpackPhoto($0) }
        
        for await photoData in unpackedPhotoStream {
            Task { @MainActor in
                thumbnailImage = photoData.thumbnailImage
                if let uiImage = UIImage(data: photoData.imageData) {
                    lastSnappedImage = Image(uiImage: uiImage)
                    lastSnappedUIImage = uiImage
                }
            }
            //savePhoto(imageData: photoData.imageData)
        }
    }
    
    private func unpackPhoto(_ photo: AVCapturePhoto) -> PhotoData? {
        guard let imageData = photo.fileDataRepresentation() else { return nil }

        guard let previewCGImage = photo.previewCGImageRepresentation(),
           let metadataOrientation = photo.metadata[String(kCGImagePropertyOrientation)] as? UInt32,
              let cgImageOrientation = CGImagePropertyOrientation(rawValue: metadataOrientation) else { return nil }
        let imageOrientation = Image.Orientation(cgImageOrientation)
        let thumbnailImage = Image(decorative: previewCGImage, scale: 1, orientation: imageOrientation)
        
        let photoDimensions = photo.resolvedSettings.photoDimensions
        let imageSize = (width: Int(photoDimensions.width), height: Int(photoDimensions.height))
        let previewDimensions = photo.resolvedSettings.previewDimensions
        let thumbnailSize = (width: Int(previewDimensions.width), height: Int(previewDimensions.height))
        
        return PhotoData(thumbnailImage: thumbnailImage, thumbnailSize: thumbnailSize, imageData: imageData, imageSize: imageSize)
    }
    
    func savePhoto(imageData: Data) {
        Task {
            do {
                try await photoCollection.addImage(imageData)
                logger.debug("Added image data to photo collection.")
            } catch let error {
                logger.error("Failed to add image to photo collection: \(error.localizedDescription)")
            }
        }
    }
    
    func loadPhotos() async {
        guard !isPhotosLoaded else { return }
        
        let authorized = await PhotoLibrary.checkAuthorization()
        guard authorized else {
            logger.error("Photo library access was not authorized.")
            return
        }
        
        Task {
            do {
                try await self.photoCollection.load()
                await self.loadThumbnail()
            } catch let error {
                logger.error("Failed to load photo collection: \(error.localizedDescription)")
            }
            self.isPhotosLoaded = true
        }
    }
    
    func loadThumbnail() async {
        guard let asset = photoCollection.photoAssets.first  else { return }
        await photoCollection.cache.requestImage(for: asset, targetSize: CGSize(width: 256, height: 256))  { result in
            if let result = result {
                Task { @MainActor in
                    self.thumbnailImage = result.image
                }
            }
        }
    }
}

fileprivate struct PhotoData {
    var thumbnailImage: Image
    var thumbnailSize: (width: Int, height: Int)
    var imageData: Data
    var imageSize: (width: Int, height: Int)
}

fileprivate extension CIImage {
    var image: Image? {
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(self, from: self.extent) else { return nil }
        return Image(decorative: cgImage, scale: 1, orientation: .up)
    }
}

fileprivate extension Image.Orientation {

    init(_ cgImageOrientation: CGImagePropertyOrientation) {
        switch cgImageOrientation {
        case .up: self = .up
        case .upMirrored: self = .upMirrored
        case .down: self = .down
        case .downMirrored: self = .downMirrored
        case .left: self = .left
        case .leftMirrored: self = .leftMirrored
        case .right: self = .right
        case .rightMirrored: self = .rightMirrored
        }
    }
}

fileprivate let logger = Logger(subsystem: "com.apple.swiftplaygroundscontent.capturingphotos", category: "DataModel")
