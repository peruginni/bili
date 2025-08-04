//import Foundation
//import ComposableArchitecture
//import SwiftUI
//import Combine
//
//struct Snaps: Reducer {
//    
//    struct CellViewModel: Hashable, Equatable, Identifiable {
//        let id: Snap.ID
//        let title: String?
//    }
//    
//    struct State: Equatable {
//        var snaps: IdentifiedArrayOf<CellViewModel>
//        @PresentationState var selectedSnap: SnapDetail.State?
//        @PresentationState var addNewSnap: SnapsAddNew.State?
//    }
//    
//    enum Action: Equatable {
//        case refresh
//        case fetchedSnaps([Snap])
//        case showSnap(Snap.ID)
//        case snapDetailPrepared(SnapDetail.State)
//        case snapDetail(PresentationAction<SnapDetail.Action>)
//        case addNewSnapTapped
//        case addNewSnapPrepared(SnapsAddNew.State)
//        case addNewSnap(PresentationAction<SnapsAddNew.Action>)
//        case didChangeLanguage
//        case didAppear
//        case didDisappear
//        case didLoad
//    }
//    
//    @Dependency(\.languageRepository) var languageRepository
//    @Dependency(\.snapRepository) var snapRepository
//        
//    private enum CancelID { case listeningToLanguageChanges }
//    
//    var body: some Reducer<State, Action> {
//        Reduce { state, action in
//            switch action {
//            case .didLoad:
//                return .send(.refresh)
//                
//            case .refresh:
//                return .run { send in
//                    let language = await languageRepository.fetchSourceLanguage()
//                    let snaps = await snapRepository.fetchAllByLanguage(language)
//                    await send(.fetchedSnaps(snaps))
//                }
//            case .fetchedSnaps(let snaps):
//                state.snaps = IdentifiedArrayOf(
//                    uniqueElements: snaps
//                        .sorted(by: { $0.updatedAt > $1.updatedAt })
//                        .map { snap in
//                            CellViewModel(
//                                id: snap.id,
//                                title: sharedDateFormatter.string(from: snap.createdAt)
//                            )
//                        }
//                )
//                return .none
//            case .showSnap(let id):
//                return .run { send in
//                    guard let snap = await snapRepository.fetch(id) else {
//                        await send(.refresh)
//                        return
//                    }
//                
//                    let addNewSnapState = SnapsAddNew.State(
//                        snap: snap,
//                        phase: .showingSnap,
//                        snapDetail: SnapDetail.State(snap: snap, sentences: [], words: [:], phase: .idle)
//                    )
//                    await send(.addNewSnapPrepared(addNewSnapState))
//                }
//                
//            case .snapDetailPrepared(let detailState):
//                state.selectedSnap = detailState
//                return .none
//            
//            case .snapDetail(.presented):
//                return .none
//                
//            case .snapDetail(.dismiss):
//                return .send(.refresh)
//                
//            case .addNewSnapTapped:
//                return .run { send in
//                    let language = await languageRepository.fetchSourceLanguage()
//                    let now = Date()
//                    let addNewSnapState = SnapsAddNew.State(
//                        snap: Snap(
//                            id: UUID(),
//                            language: language,
//                            words: [],
//                            createdAt: now,
//                            updatedAt: now
//                        ),
//                        phase: .takingPhoto
//                    )
//                    await send(.addNewSnapPrepared(addNewSnapState))
//                }
//                
//            case .addNewSnapPrepared(let addNewSnapState):
//                state.addNewSnap = addNewSnapState
//                return .none
//                             
//            case .addNewSnap(.dismiss):
//                return .send(.refresh)
//            case .addNewSnap(.presented):
//                return .none
//                
//            case .didChangeLanguage:
//                return .send(.refresh)
//                
//            case .didAppear:
//                return .run { send in
//                    for await _ in self.languageRepository.didChangeLanguageStream {
//                        await send(.didChangeLanguage)
//                    }
//                }
//                .cancellable(id: CancelID.listeningToLanguageChanges)
//                
//            case .didDisappear:
//                return .cancel(id: CancelID.listeningToLanguageChanges)
//                
//            }
//        }
//        .ifLet(\.$selectedSnap, action: /Action.snapDetail) {
//            SnapDetail()
//        }
//        .ifLet(\.$addNewSnap, action: /Action.addNewSnap) {
//            SnapsAddNew()
//        }
//    }
//}
