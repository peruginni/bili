import SwiftUI

struct CaptureView: View {
    let cameraModel = DI.cameraModel
    
    @State var viewModel: CaptureViewModel
    @FocusState private var textEditorIsFocused: Bool
    
    init(viewModel: CaptureViewModel) {
        _viewModel = State(initialValue: viewModel)
    }
    
    static let totalHeight: CGFloat = 200
    static let upperPartHeight: CGFloat = Self.totalHeight - Self.bottomPartHeight
    static let bottomPartHeight: CGFloat = 60
    
    var body: some View {
        ZStack() {
            upperPart
                
            bottomControls
                .frame(height: Self.bottomPartHeight)
                .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .onChange(of: viewModel.inputMode) { _, newMode in
            textEditorIsFocused = newMode == .text
        }
    }
    
    // MARK: - Upper Part
    @ViewBuilder
    private var upperPart: some View {
        switch viewModel.inputMode {
        case .text:
            
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.capturedText)
                    .focused($textEditorIsFocused)
                    .scrollContentBackground(.hidden)
                    .padding(.bottom, Self.bottomPartHeight)
                
                if viewModel.capturedText.isEmpty {
                    Text("Write german text to translate...")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 10)
            
        case .camera:
            if viewModel.cameraPermissionGranted == true {
                CameraPreview()
                    .background(Color.black)
                    .ignoresSafeArea()
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
        cameraModel.capturePhoto { image in
            guard let image else { return }
            viewModel.confirmPhoto(image)
        }
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
    CaptureView(viewModel: CaptureViewModel(delegate: .mock))
}

#Preview("authorized") {
    DI.cameraModel = .mock
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
