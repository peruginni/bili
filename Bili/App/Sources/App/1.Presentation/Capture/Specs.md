Specification: CaptureView & CaptureViewModel

Purpose

A reusable SwiftUI component that allows the user to capture either a photo or text input. The CaptureViewModel manages state, permissions, and event forwarding, while CaptureView renders the UI and interacts with the user.

⸻

CaptureViewModel

Responsibilities
	•	Manage current input mode (.camera or .text).
	•	Request/check camera permission and update state.
	•	Receive confirmed text or photo and forward to outside consumer via delegate closure.
	•	Expose bindings for the view (e.g. current mode, permission status).
	•	Handle transition to app settings if camera access is denied.

Properties

enum InputMode {
    case camera
    case text
}

class CaptureViewModel: ObservableObject {
    // Published state
    @Published var inputMode: InputMode = .camera
    @Published var cameraPermissionGranted: Bool? // nil = not determined, true/false = known
    @Published var capturedText: String = ""
    @Published var capturedImage: UIImage? = nil
    
    // Closures for forwarding outside
    var onTextCaptured: ((String) -> Void)?
    var onPhotoCaptured: ((UIImage) -> Void)?
    
    // Actions
    func requestCameraPermission()
    func openSystemSettings()
    func confirmText()
    func confirmPhoto(_ image: UIImage)
    func switchToTextMode()
    func switchToCameraMode()
}


⸻

CaptureView

Responsibilities
	•	Render 300px tall component split into:
	•	Upper part (70%) – depends on mode:
	•	Camera mode: live camera preview (or black screen with button if access denied).
	•	Text mode: fixed-size TextField or TextEditor.
	•	Bottom part (30%) – persistent control bar with:
	•	Mode switch buttons (camera ↔ text).
	•	Confirm button (triggers text/photo confirmation).
	•	Communicate user actions to CaptureViewModel.

Layout
	•	Fixed height: 300px.
	•	Split: 70% upper (210px), 30% lower (90px).
	•	Camera preview visually expands beneath the bottom control bar (z-index layering).
	•	When camera disabled: black background with centered “Open Settings” button.

UI States
	1.	Text Mode
	•	Upper: TextEditor bound to viewModel.capturedText.
	•	Bottom:
	•	Confirm button (“Send Text”).
	•	Switch to camera button.
	2.	Camera Mode (permission granted)
	•	Upper: camera preview layer filling view (extends under bottom bar).
	•	Bottom:
	•	Capture button (circle snap).
	•	Switch to text button.
	3.	Camera Mode (permission denied)
	•	Upper: black background.
	•	Centered “Open Settings” button.
	•	Bottom: mode switch buttons still visible.

⸻

Event Flow

Text Input
	1.	User switches to text mode.
	2.	User writes text in input field.
	3.	User taps confirm button.
	4.	CaptureViewModel.confirmText() called → forwards text via onTextCaptured.

Camera Input
	1.	User switches to camera mode.
	2.	If permission not determined → requestCameraPermission().
	3.	If granted → show live camera preview.
	4.	User taps capture button.
	5.	Captured image passed to CaptureViewModel.confirmPhoto().
	6.	Forwards image via onPhotoCaptured.

Camera Permission Denied
	•	Show black screen with “Open Settings” button → triggers openSystemSettings().

⸻

Deliverables
	•	CaptureView.swift – SwiftUI view implementing layout & interaction.
	•	CaptureViewModel.swift – ObservableObject managing state and forwarding.
	•	Integration ready: consumer injects CaptureViewModel and sets onTextCaptured / onPhotoCaptured.

