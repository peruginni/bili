//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//struct RecognizedTextView: View {
//    var store: Store<SnapsAddNew.State, SnapsAddNew.Action>
//    var retake: () -> Void
//    var addMore: () -> Void
//    var close: () -> Void
//    
//    @Environment(\.colorScheme) var colorScheme
//    
//    var body: some View {
//        VStack(spacing: 15) {
//            IfLetStore(self.store.scope(state: \.snapDetail, action: SnapsAddNew.Action.snapDetail)) { substore in
//                SnapDetailView(store: substore)
//            }
//            .layoutPriority(1)
//            
//            HStack(spacing: 15) {
//                CTAButtonView(text: "Retake", iconName: nil, action: retake)
//                CTAButtonView(text: "Add more", iconName: nil, action: addMore)
//                CTAButtonView(text: "Close", iconName: nil, action: close)
//            }
//        }
//        .navigationTitle("Recognized text")
//    }
//    
//    var myColor: Color {
//        colorScheme == .dark ? .white : .black
//    }
//}
//
////struct RecognizedTextView_Previews: PreviewProvider {
////    static var previews: some View {
////        NavigationView {
////            RecognizedTextView(
////                retake: { },
////                addMore: { },
////                close: { }
////            )
////        }
////    }
////}
