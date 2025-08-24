

import SwiftUI

struct CaptureView: View {
    @State var viewModel: CaptureViewModel
    
    init(viewModel: State<CaptureViewModel>) {
        _viewModel = viewModel
    }
    
    static let totalHeight: CGFloat = 300
    
    var body: some View {
        VStack(spacing: 0) {
            upperPart
                .frame(height: Self.totalHeight * 0.7)
                .clipped()
            
            bottomControls
                .frame(height: Self.totalHeight * 0.3)
                .background(Color(UIColor.systemGray6))
        }
        .frame(height: Self.totalHeight)
    }
    
    // MARK: - Upper Part
    @ViewBuilder
    private var upperPart: some View {
        switch viewModel.inputMode {
        case .text:
            TextEditor(text: $viewModel.capturedText)
                .padding(8)
                .background(Color.white)
        case .camera:
            if viewModel.cameraPermissionGranted == true {
                CameraPreviewView()
                    .overlay(alignment: .bottom) {
                        // empty overlay so preview goes under buttons
                        Color.clear.frame(height: Self.totalHeight * 0.3)
                    }
                    .onTapGesture {
                        snapPhoto()
                    }
            } else if viewModel.cameraPermissionGranted == false {
                ZStack {
                    Color.black
                    
                    Button("Open Settings") {
                        viewModel.openSystemSettings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundColor(.black)
                }
            } else {
                // Permission not determined
                ZStack {
                    Color.black
                    
                    Button("Grant Camera Access") {
                        viewModel.requestCameraPermission()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundColor(.black)
                }
            }
        }
    }
    
    // MARK: - Bottom Controls
    private var bottomControls: some View {
        HStack {
            if viewModel.inputMode == .camera {
                CircleButton(systemImage: "pencil", background: .white, foreground: .black) {
                    viewModel.switchToTextMode()
                }
            } else {
                CircleButton(systemImage: "camera.fill", background: .black) {
                    viewModel.switchToCameraMode()
                }
            }
            
            Spacer()
            
            if viewModel.inputMode == .camera {
                CircleButton(systemImage: "circle.fill", background: .white, foreground: .black, borderColor: .black.opacity(0.1)) {
                    snapPhoto()
                }
            } else {
                CircleButton(
                    systemImage: "arrow.up",
                    background: viewModel.capturedText.isEmpty ? .black.opacity(0.2) : .black,
                    foreground: .white,
                    borderColor: viewModel.capturedText.isEmpty ? .clear : .black.opacity(0.1)
                ) {
                    viewModel.confirmText()
                }
                .disabled(viewModel.capturedText.isEmpty)
            }
        }
        .padding(.horizontal)
    }
    
    func snapPhoto() {
        // Simulate photo capture with a placeholder image
        let dummyImage = UIImage(systemName: "camera.fill")!
        viewModel.confirmPhoto(dummyImage)
    }
}

// MARK: - Camera Preview Placeholder
struct CameraPreviewView: View {
    var body: some View {
        ZStack {
            Color.gray
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
        }
    }
}

@MainActor
private func makeCaptureView() -> some View {
    CaptureView(
        viewModel: State(
            initialValue: CaptureViewModel(delegate: .mock)
        )
    )
}

#Preview("authorized") {
    DI.cameraPermissionService = .mockAuthorized
    return makeCaptureView()
}

#Preview("denied") {
    DI.cameraPermissionService = .mockDenied
    return makeCaptureView()
}

#Preview("not determined") {
    DI.cameraPermissionService = .mockNotDetermined
    return makeCaptureView()
}
