import SwiftUI
import ComposableArchitecture

struct CaptureScreenView: View {
    let store: StoreOf<CaptureScreen>
    let cameraModel: CameraClientObservableWrapper

    @FocusState private var isInputActive: Bool
    @State private var selectedDetent: PresentationDetent = .captureBase
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(
                            store.scope(state: \.capturedItems, action: \.capturedItems)
                        ) { childStore in
                            CapturedItemView(store: childStore)
                        }
                        
                        // Invisible guide representing last item in scroll view, where we can scroll to
                        Text("")
                            .id("last")
                    }
                    .padding()
                }
                .onChange(of: viewStore.shouldFocusLastInput) {
                    withAnimation {
                        proxy.scrollTo("last", anchor: .bottom)
                    }
                }
                .onTapGesture {
                    isInputActive = false
                }
            }
            .sheet(isPresented: Binding(
                get: { true },
                set: { _ in }
            )) {
                sheetContent
                .ignoresSafeArea(.all)
                .interactiveDismissDisabled()
                .presentationBackgroundInteraction(.enabled)
                .presentationDragIndicator(.automatic)
                .presentationDetents([.captureBase, .captureBig], selection: $selectedDetent)
                .presentationCornerRadius(30)
            }
        }
    }

    @ViewBuilder
    private var sheetContent: some View {
        ScrollView {
            VStack {
                CaptureModeSwitcherView(
                    store: store.scope(
                        state: \.captureModeSwitcher,
                        action: \.captureModeSwitcher
                    ),
                    cameraModel: cameraModel,
                    isInputActive: $isInputActive
                )
                
                if case .captureBig = selectedDetent {
                    
                    HStack(spacing: 8) {
                        ActionButton(icon: "figure.walk", label: "Practice")
                        ActionButton(icon: "book", label: "Dict")
                        ActionButton(icon: "gearshape", label: "Settings")
                    }
                    .padding(.top, 30)
                    .padding(.bottom, 20)
                }
                                
            }
            .padding()
        }
        .scrollDisabled(true)
    }
}

extension PresentationDetent {
    static let captureBase: PresentationDetent = .height(110)
    static let captureBig: PresentationDetent = .height(240)
}

private struct BarDetent: CustomPresentationDetent {
    static func height(in context: Context) -> CGFloat? {
        44
    }
}

struct ActionButton: View {
    var icon: String
    var label: String
    var action: () -> Void = {}
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.footnote)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .contentShape(RoundedRectangle(cornerRadius: 20))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .buttonStyle(PlainButtonStyle()) // Prevents button from shrinking
    }
}

#Preview {
    CaptureScreenView(
        store: Store(
            initialState: .mock,
            reducer: { CaptureScreen() }
        ) {
            $0.cameraPermissionClient = CameraPermissionClient(
                requestCameraPermission: {
                    // Simulate granted permission
                    return true
                }
            )
        },
        cameraModel: .mock
    )
}

extension CaptureScreen.State {
    static var mock = Self(
        languageSelection: .mock,
        capturedItems: [
            .mock(text: "Hello"),
            .mock(text: "How are you?"),
        ]
    )
}
