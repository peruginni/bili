import Foundation
import SwiftUI
import SwiftUINavigation
import ComposableArchitecture

struct AppView: View {
    var body: some View {
        NavigationStack {
            SnapsView()
        }
    }
}
