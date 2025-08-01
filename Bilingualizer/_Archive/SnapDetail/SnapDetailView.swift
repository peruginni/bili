//import Foundation
//import ComposableArchitecture
//import SwiftUI
//
//struct SnapDetailView: View {
//    
//    let store: StoreOf<SnapDetail>
//    @Environment(\.colorScheme) var colorScheme
//    
//    @State private var isShowingMore = false
//    @State private var isRenaming = false
//    @State private var isSelectingOriginalLanguage = false
//    @State private var isSelectingTranslationLanguage = false
//    @State private var isShowingMemorize = false
//    
//    var body: some View {
//        NavigationView {
//            WithViewStore(self.store, observe: { $0 }) { viewStore in
//                Group {
//                    if viewStore.state.sentences.isEmpty, viewStore.state.phase != .idle {
//                        VStack(spacing: 16) {
//                            ProgressView()
//                                .progressViewStyle(.circular)
//                            Text("First translation takes a bit longer, because I need to download dictionary to be able translate your words. Please be patient.")
//                                .multilineTextAlignment(.center)
//                                .padding(.horizontal, 25)
//                        }
//                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                    } else {
//                        List {
//                            ForEach(viewStore.state.sentences) { sentence in
//                                SnapDetailWordsView(
//                                    words: sentence.words,
//                                    didSelectWord: { item in
//                                        viewStore.send(.wordInSentenceDetailTapped(item, sentence))
//                                    }
//                                )
//                            }
//                        }
//                        .listStyle(.plain)
//                    }
//                }
//                .navigationTitle(
//                    viewStore.state.snap.name.isEmpty
//                    ? sharedDateFormatter.string(from: viewStore.state.snap.createdAt)
//                    : viewStore.state.snap.name
//                )
//                .navigationBarTitleDisplayMode(.inline)
//                .toolbar {
//                    ToolbarItem(placement: .primaryAction) {
//                        Menu {
//                            Button(action: {
//                                isRenaming = true
//                            }) {
//                                Label("Rename", systemImage: "pencil")
//                            }
//                            Button(action: {
//                                viewStore.send(.didTapRetake)
//                            }) {
//                                Label("Retake", systemImage: "repeat")
//                            }
//                            Button(action: {
//                                viewStore.send(.didTapAddMore)
//                            }) {
//                                Label("Add more text", systemImage: "plus")
//                            }
//                            Button(
//                                role: .destructive,
//                                action: {
//                                    viewStore.send(.didTapDelete)
//                                },
//                                label: {
//                                    Label("Delete", systemImage: "trash")
//                                }
//                            )
//                            
//                        } label: {
//                            Image(systemName: "ellipsis.circle")
//                                .foregroundColor(.accentColor)
//                        }
//                    }
//                    
//                }
//                .alert("Rename", isPresented: $isRenaming) {
//                    TextField(
//                        "",
//                        text: viewStore.binding(get: \.snap.name, send: SnapDetail.Action.nameChanged)
//                    )
//                    Button("Done", action: {
//                        viewStore.send(.saveChangedName)
//                    })
//                }
//                .sheet(
//                    isPresented: viewStore.binding(
//                        get: { $0.isShowingWordInSentenceDetail },
//                        send: .wordInSentenceDetailDismissed
//                    ),
//                    content: {
//                        IfLetStore(self.store.scope(state: \.wordInSentenceDetail, action: SnapDetail.Action.wordInSentenceDetailAction)) { substore in
//                            WordInSentenceDetailView(store: substore)
//                                .presentationDetents([.medium, .large])
//                        }
//                    }
//                )
//                .task {
//                    viewStore.send(.translateIfNeeded)
//                }
//            }
//        }
//    }
//}
//
//struct SnapDetailView_Preview: PreviewProvider {
//    static let mockKafkaState = SnapDetail.State(
//        snap: Snap(
//            id: UUID(),
//            language: .english,
//            rawCapturedParts: [["test"]],
//            sentences: [],
//            words: [],
//            name: "",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        sentences: [
//            .init(
//                id: UUID(),
//                words: SnapDetailWordsView.makeMockSentence(
//                    "Ich trete aus dem Haus um einen kleinen Spaziergang zu machen. Es ist shönes Wetter aber die Gasse ist auffallend leer, nur in der Ferne steht ein städtisher Beidensteter mit dem Wasserschlauch in der Hand und spritzt einen ungeheueren Bogen Wassers die Gasse entlang. »Unerhört« sage ich und prüfe die Spannung des Bogens.",
//                    aboveWords: [
//                        "trete": "join",
//                        "Haus": "House",
//                        //"Spaziergang": "walk",
//                        "kleinen": "small",
//                        "shönes": "beautiful",
//                        "Gasse": "alley",
//                        "auffallend": "strikingly",
//                        "leer": "empty",
//                        "Ferne": "distance",
//                        "steht": "stands",
//                        "städtisher": "urban",
//                        "Beidensteter": "servant",
//                        "Wasserschlauch": "water hose",
//                    ]
//                )
//            ),
//        ],
//        words: [:],
//        phase: .idle
//    )
//    
//    static let mockKafkaStateToFix = SnapDetail.State(
//        snap: Snap(
//            id: UUID(),
//            language: .english,
//            rawCapturedParts: [["test"]],
//            sentences: [],
//            words: [],
//            name: "",
//            createdAt: Date(),
//            updatedAt: Date()
//        ),
//        sentences: [
//            .init(
//                id: UUID(),
//                words: SnapDetailWordsView.makeMockSentence(
//                    "Ich trete aus dem Haus um einen kleinen Spaziergang zu machen",
//                    aboveWords: [
//                        "trete": "join",
//                        "Haus": "House",
//                        "kleinen": "small"
//                    ]
//                )
//            ),
//            .init(
//                id: UUID(),
//                words: SnapDetailWordsView.makeMockSentence(
//                    "Es ist shönes Wetter aber die Gasse ist auffallend leer, nur in der Ferne steht ein städtisher Beidensteter mit dem Wasserschlauch in der Hand und spritzt einen ungeheueren Bogen Wassers die Gasse entlang.",
//                    aboveWords: [
//                        "shönes": "beautiful",
//                        "Gasse": "alley",
//                        "auffallend": "strikingly",
//                        "leer": "empty",
//                        "Ferne": "distance",
//                        "steht": "stands",
//                        "städtisher": "urban",
//                        "Beidensteter": "servant",
//                        "Wasserschlauch": "water hose",
//                    ]
//                )
//            ),
//            .init(
//                id: UUID(),
//                words: SnapDetailWordsView.makeMockSentence(
//                    "»Unerhört« sage ich und prüfe die Spannung des Bogens.",
//                    aboveWords: [:]
//                )
//            )
//        ],
//        words: [:],
//        phase: .idle
//    )
//    
//    static var basicView: some View {
//        SnapDetailView(
//            store: Store(
//                initialState: mockKafkaState
//            ) { EmptyReducer() }
//        )
//    }
//    
//    static var withWordDetailView: some View {
//        ZStack {
//            basicView
//            .overlay {
//                Rectangle()
//                    .fill(Color.black)
//                    .opacity(0.15)
//            }
//            .ignoresSafeArea()
//            
//            ZStack {
//                WordInSentenceDetailView(
//                    store: Store(
//                        initialState: WordInSentenceDetail.State(
//                            sourceLanguage: .german,
//                            targetLanguage: .english,
//                            word: Word(
//                                word: "Spaziergang",
//                                sourceLanguage: .german,
//                                translations: [
//                                    .english: "walk"
//                                ],
//                                createdAt: Date(),
//                                updatedAt: Date(),
//                                isArchived: true
//                            ),
//                            originalSentence: .init(
//                                text: "",
//                                language: .german
//                            ),
//                            translatedSentence: .init(
//                                text: "I drive out of house to take a short walk",
//                                language: .english
//                            )
//                        )
//                    ) { EmptyReducer() }
//                )
//                
//                Rectangle()
//                    .fill(Color.black.opacity(0.15))
//                    .frame(width: 40, height: 5)
//                    .cornerRadius(5)
//                    .padding(4)
//                    .frame(maxHeight: .infinity, alignment: .top)
//            }
//            .cornerRadius(16)
//            .ignoresSafeArea()
//            .frame(height: 400)
//            .frame(maxHeight: .infinity, alignment: .bottom)
//        }
//    }
//    
//    
//    static var previews: some View {
//        
//        basicView
//        
//        withWordDetailView
//        
//        
////            .sheet(isPresented: .constant(true)) {
////                Text("test")
////                    .presentationDetents([.medium, .large])
////            }
//        
//    
//            SnapDetailView(
//                store: Store(
//                    initialState: SnapDetail.State(
//                        snap: Snap(
//                            id: UUID(),
//                            language: .english,
//                            rawCapturedParts: [["test"]],
//                            sentences: [],
//                            words: [],
//                            name: "",
//                            createdAt: Date(),
//                            updatedAt: Date()
//                        ),
//                        sentences: [],
//                        words: [:],
//                        phase: .isTranslating
//                    )
//                ) { EmptyReducer() }
//            )
//
//    }
//}
//
//extension SnapDetailWordsView {
//    static func makeMockSentence(_ sentence: String, aboveWords: [String: String]) -> [SnapDetailWordsView.Item] {
//        
//        return sentence.components(separatedBy: " ")
//            .map {
//                SnapDetailWordsView.Item(
//                    id: UUID().uuidString,
//                    word: $0,
//                    above: aboveWords[$0]
//                )
//            }
//    }
//}
