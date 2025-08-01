////
////  File.swift
////  
////
////  Created by Ondra on 18.05.2023.
////
//
//import Foundation
//import SwiftUI
//import ComposableArchitecture
//
//struct SnapsGridView: View {
//    let items: IdentifiedArrayOf<Snaps.CellViewModel>
//    let didTapItem: (Snaps.CellViewModel) -> Void
//    
//    var body: some View {
//        LazyVGrid(columns: gridLayout, spacing: 5) {
//            ForEach(items, id: \.self) { item in
//                SnapsCellView(title: item.title)
//                    .onTapGesture {
//                        didTapItem(item)
//                    }
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 150)
//            }
//        }
//        .padding(.horizontal)
//    }
//    
//    var gridLayout: [GridItem] {
//        let columns = [
//            GridItem(.flexible()),
//            GridItem(.flexible()),
//            GridItem(.flexible()),
//        ]
//        return columns
//    }
//}
//
//private extension Array {
//    func chunked(into size: Int) -> [[Element]] {
//        return stride(from: 0, to: count, by: size).map {
//            Array(self[$0 ..< Swift.min($0 + size, count)])
//        }
//    }
//}
//
//struct SnapsGridView_Preview: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            ScrollView(.vertical) {
//                SnapsGridView(
//                    items: .init(uniqueElements: items),
//                    didTapItem: { _ in }
//                )
//            }
//        }
//    }
//}
//
//private let lipsumText = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam dapibus fermentum ipsum. Nam quis nulla. Nullam rhoncus aliquam metus. Nulla est. Aenean fermentum risus id tortor. Duis risus. Nullam dapibus fermentum ipsum. Fusce suscipit libero eget elit. Aenean vel massa quis mauris vehicula lacinia. Morbi leo mi, nonummy eget tristique non, rhoncus non leo"
//
//private let items: [Snaps.CellViewModel] = (1...50).map {
//    Snaps.CellViewModel(
//        id: UUID(),
//        title: "Test \($0)"
//    )
//}
