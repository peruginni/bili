import SwiftUI
import ComposableArchitecture

struct CapturedItemView: View {
    let store: StoreOf<CapturedItem>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                
                HStack {
                    Text(formattedDate(viewStore.createdAt))
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                }
                
                VStack {
                    
                    if let translation = viewStore.translation {
                        Text(translation)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    } else if let text = viewStore.text {
                        Text(text)
                            .padding(10)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                    } else if let photo = viewStore.photo {
                        Image(uiImage: photo)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } 
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
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
    List {
        Section("User inserts Photo -> .recognizingTextInImage") {
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
        }
        Section("Recognized photo text -> .translating") {
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
        }
        Section ("User inserts Text -> .translating") {
            CapturedItemView(
                store: Store(
                    initialState: CapturedItem.State(
                        languageSelection: .mock,
                        status: .translating,
                        photo: nil,
                        text: "Hello",
                        translation: nil
                    ),
                    reducer: { CapturedItem() }
                )
            )
        }
        Section("Text translated -> .translated") {
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
