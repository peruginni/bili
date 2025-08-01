import Foundation
import ComposableArchitecture
import SwiftUI

struct WordInSentenceDetailView: View {
    let store: StoreOf<WordInSentenceDetail>
    
    var body: some View {
        NavigationView {
            WithViewStore(self.store, observe: { $0 }) { viewStore in
                List {
                    Section {
                        HStack(alignment: .center) {
                            
                            Text(viewStore.state.wordOriginal)
                                .font(.body)
                                .fontWeight(.bold)
                                .frame(alignment: .center)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = viewStore.state.wordOriginal
                                    }) {
                                        Text("Copy to clipboard")
                                        Image(systemName: "doc.on.doc")
                                    }
                                }
                            
                            Image(systemName: "arrow.right")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .padding()
                            
                            Text(viewStore.state.wordTranslation ?? "")
                                .font(.body)
                                .fontWeight(.bold)
                                .frame(alignment: .center)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = viewStore.state.wordTranslation
                                    }) {
                                        Text("Copy to clipboard")
                                        Image(systemName: "doc.on.doc")
                                    }
                                }
                            
                        }
                        Toggle(
                            "Hide word, because I know it.",
                            isOn: viewStore.binding(
                                get: \.word.isArchived,
                                send: { value in
                                    if value {
                                        return .archive
                                    } else {
                                        return .unarchive
                                    }
                                }
                            )
                        ).padding(.vertical, 5)
                    }
                    
                    if let translatedSentence = viewStore.state.translatedSentence {
                        Section("Full Sentence in \(translatedSentence.language.emoji)") {
                            VStack {
                                Text("\(translatedSentence.text)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(packageResource: "google-translate", ofType: "png")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                        }
                    }
                    
                    
                    if let url = makeURLForState(viewStore.state) {
                        Section() {
                            Link(
                                "Search \"\(viewStore.state.wordOriginal)\" on internet",
                                destination: url
                            )
                        }
                    }
                    
                }
                .listStyle(.insetGrouped)
                .task {
                    viewStore.send(.load)
                }
            }
        }
    }
    
    func makeURLForState(_ state: WordInSentenceDetail.State) -> URL? {
        guard
            let word = state.wordOriginal.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let language = state.targetLanguage.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        else { return nil }
        let string = "https://duckduckgo.com/?va=v&t=ha&q=%22\(word)%22+in+\(language)"
        return URL(string: string)
    }
}

struct WordInSentenceDetail_Previews: PreviewProvider {

    static var previews: some View {
        WordInSentenceDetailView(
            store: Store(
                initialState: .init(
                    sourceLanguage: .english,
                    targetLanguage: .czech,
                    word: .init(
                        word: "Hello",
                        sourceLanguage: .english,
                        translations: [Language.czech : "Ahoj"],
                        createdAt: Date(),
                        updatedAt: Date(),
                        isArchived: false
                    ),
                    originalSentence: .init(
                        text: "Hello, how are you?",
                        language: .english
                    )
                )
            ) { WordInSentenceDetail() }
        )
    }
}
