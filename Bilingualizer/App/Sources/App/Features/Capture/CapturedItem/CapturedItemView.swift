import SwiftUI
import ComposableArchitecture

struct CapturedItemView: View {
    let store: StoreOf<CapturedItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                Group {
                    if let text = viewStore.translation ?? viewStore.text {
                        Text(text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                    } else if let photo = viewStore.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
                .cornerRadius(10)
                
                HStack(alignment: .center) {
                    Text("\(formattedDate(viewStore.createdAt)) · \(viewStore.status.rawValue)")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    
                    Spacer()
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

#Preview() {
    VStack {
        CapturedItemView(
            store: Store(
                initialState: CapturedItem.State(
                    languageSelection: .mock,
                    status: .recognizingTextInImage,
                    photo: CapturedItem.State.photo,
                    text: nil,
                    translation: nil
                ),
                reducer: { CapturedItem() }
            )
        )
        CapturedItemView(
            store: Store(
                initialState: CapturedItem.State(
                    languageSelection: .mock,
                    status: .translating,
                    photo: CapturedItem.State.photo,
                    text: "Hello",
                    translation: nil
                ),
                reducer: { CapturedItem() }
            )
        )
        CapturedItemView(
            store: Store(
                initialState: CapturedItem.State(
                    languageSelection: .mock,
                    status: .translated,
                    photo: nil,
                    text: "Hello",
                    translation: "Ahoj"
                ),
                reducer: { CapturedItem() }
            )
        )
    }
}

extension CapturedItem.State {
    static var photo = UIImage(named: "captured-item-example", in: Bundle.module, with: nil) ?? UIImage()
    static var mock = mock()
    static func mock(text: String = "Hello") -> Self {
        return .init(
            languageSelection: .mock,
            photo: Self.photo,
            text: text
        )
    }
}
