import Foundation
import SwiftUI
import ComposableArchitecture

struct ExerciseSessionView: View {
    
    let store: StoreOf<ExerciseSession>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Group {
            if let currentWord = viewStore.state.currentWord {
                ZStack {
                    List {
                        Section {
                            ProgressView("Progress (done \(viewStore.pastWords.count) from \(viewStore.totalWordsCount))", value: viewStore.progress)
                                .progressViewStyle(.linear)
                                .padding(.vertical)
                        }
                        
                        
                        Section {
                            Text(currentWord.source)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .frame(alignment: .center)
                                .padding()
                            
                            Text(currentWord.translation ?? "")
                                .font(.largeTitle)
                                .frame(alignment: .center)
                                .padding()
                        } footer: {
                            HStack {
                                Text("Archive word, because I know it well")
                                Toggle(isOn: viewStore.binding(get: \.isArchivedWord, send: ExerciseSession.Action.toggleArchiveForCurrentWord)) {
                                }
                                .labelsHidden()
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        }
                    }
                    .listStyle(.insetGrouped)
                    .multilineTextAlignment(.center)
                    
                    VStack {
                        Spacer()
                        
                        HStack {
                            // TODO use player like icons and pause/play
                            if !viewStore.state.pastWords.isEmpty {
                                Button {
                                    viewStore.send(.prevWord)
                                } label: {
                                    Text("Previous")
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                        .padding()
                                }
                                .buttonStyle(.bordered)
                            }
                            
                            if !viewStore.state.nextWords.isEmpty {
                                Button {
                                    viewStore.send(.nextWord)
                                } label: {
                                    Text("Next")
                                        .font(.largeTitle)
                                        .foregroundColor(.black)
                                        .padding()
                                }
                                .buttonStyle(.bordered)
                                
                            }
                            
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding()
                    .padding(.bottom, 20)
                }
            } else {
                VStack(alignment: .center, spacing: 16) {
                    
                    Spacer()
                    VStack {
                        Text("🎉")
                            .font(.system(size: 200))
                        Text("All done")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                        
                        CTAButtonView(
                            text: "Practise more 💪",
                            iconName: nil
                        ) {
                            viewStore.send(.shuffle)
                        }
                    }
                    Spacer()
                    
                }
            }
        }
            .navigationBarTitleDisplayMode(.inline)
            .task {
                viewStore.send(.didLoad)
            }
            .onDisappear {
                viewStore.send(.didDisappear)
            }
            .onAppear() {
                viewStore.send(.didAppear)
            }
        }
    }
}

struct ExerciseSessionView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseSessionView(
            store: Store(
                initialState: ExerciseSession.State(
                    sourceLanguage: Language.english,
                    translationLanguage: Language.czech,
                    allWords: [
                        ExerciseSession.State.WordViewModel(id: "1", source: "Hello", translation: "Ahoj"),
                        ExerciseSession.State.WordViewModel(id: "2", source: "A", translation: "B"),
                        ExerciseSession.State.WordViewModel(id: "3", source: "A", translation: "B")
                    ],
                    autoContinue: false
                )
            ) {
                ExerciseSession()
            }
        )
    }
}
