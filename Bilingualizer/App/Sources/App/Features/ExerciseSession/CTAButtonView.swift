import SwiftUI

struct CTAButtonView: View {
    let text: String
    let iconName: String?
    let action: () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if let iconName {
                    Image(systemName: iconName)
                }
                Text(text)
                    .font(.title)
                    .fontWeight(.bold)
            }
        }
        .buttonStyle(.plain)
        .padding(30)
        .background(.tint)
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(radius: 10)
    }
}

// TODO SwiftUI preview
