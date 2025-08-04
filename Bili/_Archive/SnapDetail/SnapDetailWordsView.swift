//import SwiftUI
//import Foundation
//
//struct SnapDetailWordsView: View {
//    
//    struct Item: Equatable {
//        let id: Word.ID?
//        let word: String
//        let above: String?
//    }
//    
//    let topPadding: CGFloat
//    let offset: CGFloat
//    let baseFont: Font
//    let smallFont: Font
//    let words: [Item]
//    let didSelectWord: (Item) -> Void
//    
//    public init(
//        topPadding: CGFloat = 7,
//        offset: CGFloat = 16,
//        baseFontSize: CGFloat = 20,
//        smallFontSize: CGFloat = 20 * 0.6,
//        words: [Item],
//        didSelectWord: @escaping (Item) -> Void
//    ) {
//        self.topPadding = topPadding
//        self.offset = offset
//        self.words = words
//        self.didSelectWord = didSelectWord
//        baseFont = .system(size: baseFontSize)
//        smallFont = .system(size: smallFontSize)
//    }
//    
//    public var body: some View {
//        FlowLayout(mode: .scrollable, items: words, itemSpacing: 3) { item in
//            if let above = item.above {
//                ZStack {
//                    Text(above)
//                        .font(smallFont)
//                        .opacity(0.3)
//                        .offset(y: -offset)
//                        .fixedSize()
//                        .frame(width: 1, height: 1)
//                    /// alternativni texty bz tadz mohlz problikavat po sekunde
//                    /// alternativni texty bz tadz mohlz problikavat po sekunde
//                    Text(item.word)
//                        .font(baseFont)
//                }
//                .padding(.top, topPadding)
//                .onTapGesture {
//                    didSelectWord(item)
//                }
//            } else {
//                Text(item.word)
//                    .font(baseFont)
//                    .padding(.top, topPadding)
//                    .onTapGesture {
//                        didSelectWord(item)
//                    }
//            }
//        }
//    }
//}
//
//struct SnapDetailWordsView_Previews: PreviewProvider {
//    
//    static let words: [SnapDetailWordsView.Item] = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam dapibus fermentum ipsum. Nam quis nulla. Nullam rhoncus aliquam metus. Nulla est. Aenean fermentum risus id tortor. Duis risus. Nullam dapibus fermentum ipsum. Fusce suscipit libero eget elit. Aenean vel massa quis mauris vehicula lacinia. Morbi leo mi, nonummy eget tristique non, rhoncus non leo."
//        .components(separatedBy: " ")
//        .map {
//            .init(
//                id: UUID().uuidString,
//                word: $0,
//                above: $0.contains("s") ? "běžet" : nil
//            )
//        }
//    
//    static let test1: some View = SnapDetailWordsView(
//        words: Self.words,
//        didSelectWord: { print($0) }
//    )
//        
//    static var previews: some View {
//        ScrollView {
//            SnapDetailWordsView(
//                words: Self.words,
//                didSelectWord: { print($0) }
//            )
//            Text("--")
//            SnapDetailWordsView(
//                words: Self.words,
//                didSelectWord: { print($0) }
//            )
//        }
//    }
//}
//
////HStack {
////
////
////    ZStack {
////        Text("z")
////            .background(.red)
////            .offset(y: -20)
////        Text("from")
////            .background(.green)
////    }
////    .background(.blue)
////
////    ZStack {
////        Text("běžet")
////            .background(.red)
////            .offset(y: -20)
////            .fixedSize()
////            .frame(width: 1, height: 1)
////        Text("run")
////            .background(.green)
////    }
////    .background(.blue)
////
////
////}
////.background(.yellow)
