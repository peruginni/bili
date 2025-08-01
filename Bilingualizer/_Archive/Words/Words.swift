import Foundation
import ComposableArchitecture
import SwiftUI

@Reducer
struct Words: Reducer {
    
    @ObservableState
    struct State: Equatable {
        enum Filter: LocalizedStringKey, CaseIterable, Hashable {
            case active = "Active"
            case archived = "Archived"
        }
        let sourceLanguage: Language
        let targetLanguage: Language
        var filter: Filter = .active
        var items: IdentifiedArrayOf<WordRow.State> = []
        // TODO change to didSet, this seems too difficult
        var filteredItems: IdentifiedArrayOf<WordRow.State> {
            switch filter {
            case .active: return self.items.filter { !$0.isArchived }
            case .archived: return self.items.filter(\.isArchived)
            }
        }
    }
    
    enum Action: Equatable {
        case load
        case didSelectFilter(State.Filter)
        case didLoadItems(IdentifiedArrayOf<WordRow.State>)
        case items(IdentifiedActionOf<WordRow>)
    }
    
    @Dependency(\.translationClient) var translationClient
    @Dependency(\.wordRepository) var wordRepository
    @Dependency(\.speechClient) var speechClient
    
    private enum CancelID {
        case listeningToLanguageChanges
        case reading
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .load:
                let state = state
                return .run { send in
                    let words = await wordRepository.fetchAllByLanguage(state.sourceLanguage)
                    var items: IdentifiedArrayOf<WordRow.State> = []
                    for word in words {
                        let item = WordRow.State(
                            word: word,
                            sourceLanguage: state.sourceLanguage,
                            targetLanguage: state.targetLanguage
                        )
                        items.append(item)
                    }
                    items.sort(by: { $0.originalText < $1.originalText })
                    await send(.didLoadItems(items))
                }
            
            case .didLoadItems(let items):
                state.items = items
                return .none
                
            case .didSelectFilter(let filter):
                state.filter = filter
                return .none
                
            case .items(.element(_, let action)):
                switch action {
                case .archive,
                     .unarchive,
                     .delete:
                    return .send(.load)
                case .tapRow:
                    return .none
                }
            }
        }
        .forEach(\.items, action: \.items) {
            WordRow()
        }
    }
}
