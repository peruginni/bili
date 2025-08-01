import Foundation
import SwiftUI
import ComposableArchitecture

struct ExercisesView: View {
    
    let store: StoreOf<Exercises>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                List {
                    
                    Section {
                        HStack {
                            Text("New words: \(viewStore.activeWordsCount)")
                            
                            Spacer()
                            
                            Text("Known words: \(viewStore.archivedWordsCount)")
                        }
                        .padding(.vertical, 5)
                    
                        Toggle(isOn: viewStore.binding(get: \.autoContinue, send: Exercises.Action.toggleAutoContinue)) {
                            Text("Continue to next word")
                                .frame(maxWidth: .infinity, alignment:  .leading)
                        }
                        .padding(.vertical, 5)
                    
                        VStack {
                            Stepper {
                                HStack {
                                    Text("\(viewStore.state.numberOfWordsToExercise)")
                                        .font(.largeTitle)
                                        .fontWeight(.heavy)
                                    Text("words in exercise")
                                        .frame(maxWidth: .infinity, alignment:  .leading)
                                }
                            } onIncrement: {
                                viewStore.send(
                                    .didChangeNumberWordsToExerciseTo(
                                        min(
                                            viewStore.activeWordsCount,
                                            viewStore.state.numberOfWordsToExercise + 20
                                        )
                                    )
                                )
                            } onDecrement: {
                                viewStore.send(
                                    .didChangeNumberWordsToExerciseTo(
                                        max(
                                            1,
                                            viewStore.state.numberOfWordsToExercise - 20
                                        )
                                    )
                                )
                            }
                        }
                    }
                    
                    Section {
                        Text("During exercise, I will repeat each word twice so you better remember it.")
                            .padding(.vertical, 10)
                        Text("ℹ️ Tip: Build habit. Listen to words every time you wash dishes.")
                            .padding(.vertical, 10)
                    }
                    
                }
                .listStyle(.insetGrouped)
                
                VStack {
                    if viewStore.state.activeWordsCount == 0 {
                        Text("Add some words to enable exercising")
                    }
                    CTAButtonView(
                        text: "Start",
                        iconName: nil
                    ) {
                        viewStore.send(.didTapStart)
                    }
                    .disabled(viewStore.state.activeWordsCount == 0)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                .padding(.bottom, 20)
            }
            .navigationTitle("Listen Words")
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.isSessionShown },
                    send: .exerciseSessionDismissed
                ),
                content: {
                    IfLetStore(self.store.scope(state: \.session, action: Exercises.Action.exerciseSessionAction)) { substore in
                        ExerciseSessionView(store: substore)
                    }
                }
            )
            .onAppear {
                viewStore.send(.didAppear)
            }
            .onDisappear {
                viewStore.send(.didDisappear)
            }
        }
    }
}

struct ExercisesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExercisesView(
                store: Store(
                    initialState: .init()
                ) { Exercises() }
            )
        }
    }
}
