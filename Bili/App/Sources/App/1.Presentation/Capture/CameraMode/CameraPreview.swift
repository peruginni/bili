import SwiftUI
import UIKit

struct CameraPreview: UIViewControllerRepresentable {
    @ObservedObject var cameraModel: CameraClientObservableWrapper
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MyVC()
        controller.cameraModel = cameraModel
        let previewLayer = cameraModel.getPreviewLayer()
        //previewLayer.frame = UIScreen.main.bounds
        controller.view.layer.addSublayer(previewLayer)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

class MyVC: UIViewController {
    
    weak var cameraModel: CameraClientObservableWrapper?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraModel?.startSession()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cameraModel?.stopSession()
    }
}
