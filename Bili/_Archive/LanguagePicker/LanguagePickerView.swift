import Foundation
import SwiftUI
import ComposableArchitecture

struct LanguagePickerView: View {
    
    let store: StoreOf<LanguagePicker>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Button(
                action: {
                    viewStore.send(.showLanguagePicker)
                },
                label: {
                    HStack(spacing: 2) {
                        if let language = viewStore.state.selectedLanguage {
                            Text(language.emoji).font(.largeTitle)
                        }
                    }
                }
            )
            .task {
                viewStore.send(.didLoad)
            }
            .confirmationDialog(
                viewStore.state.mode == .sourceLanguage
                ? "Source language"
                : "Target language",
                isPresented: viewStore.binding(
                    get: { $0.isLanguagePickerPresented },
                    send: .languagePickerDismissed
                )
            ) {
                ForEach(viewStore.languages) { language in
                    Button(language.title) {
                        viewStore.send(.didSelectLanguage(language))
                    }
                }
            } message: {
                Text(viewStore.state.mode == .sourceLanguage
                     ? "Source language"
                     : "Target language")
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: { $0.isChangingLanguage },
                    send: .didSendDuringChangeOfLanguage
                ),
                content: {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(.circular)
                        VStack(spacing: 8) {
                            Text("Switching language...")
                                .font(.headline)
                            Text("If you have switched to this language for the first time, I need a while to download dictionary to be able translate your words. Please be patient.")
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding()
                    .presentationDetents([.medium])
                }
            )
        }
    }
}

struct LanguagePickerView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Text("Test")
                .navigationBarItems(leading: HStack {
                    LanguagePickerView(
                        store: Store(
                            initialState: LanguagePicker.State(
                                mode: .sourceLanguage,
                                selectedLanguage: nil,
                                isLanguagePickerPresented: false,
                                isChangingLanguage: true
                            )
                        ) { LanguagePicker() }
                    )
                })
        }
    }
}
