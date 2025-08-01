import ComposableArchitecture
import SwiftUI
@testable import App

var capturedSnapView: AnyView {
//    let view = SnapDetailWordsView_Previews.test1
    let view = SnapDetailView_Preview.withWordDetailView
    return AnyView(view)
}
