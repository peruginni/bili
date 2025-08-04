import ComposableArchitecture
import SwiftUI
@testable import App

struct FakeCapturePhotoView: View {
    @State var isPresented: Bool = false
    @State var image: Image? = UIImage(named: "bookPhoto", in: .module, with: nil).map { Image(uiImage: $0) }
    
    var body: some View {
        TakingPhotoView(
            viewfinderImage: $image,
            takePhoto: { },
            isInProgress: false,
            showButton: true
        )
    }
}

var capturePhotoView: AnyView {
    let view = FakeCapturePhotoView()
    .background(Color.black)
  return AnyView(view)
}
