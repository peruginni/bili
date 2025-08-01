import Foundation
import SwiftUI
import ComposableArchitecture

struct NoCapturedWordsYetView: View {

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 5) {
                Image(systemName: "camera")
                    .imageScale(.large)
                Image(systemName: "book")
                    .imageScale(.large)
                Image(systemName: "person.text.rectangle")
                    .imageScale(.large)
                Image(systemName: "newspaper")
                    .imageScale(.large)
                Image(systemName: "doc.text")
                    .imageScale(.large)
            }
            Text("No captured words yet")
                .font(.title3)
                .fontWeight(.bold)
            Text("Take picture of words you don't understand. I will help you learn those words! ✌️")
                .multilineTextAlignment(.center)
        }
    }
}

struct NoCapturedWordsYetView_Preview: PreviewProvider {
    static var previews: some View {
        NoCapturedWordsYetView()
    }
}
