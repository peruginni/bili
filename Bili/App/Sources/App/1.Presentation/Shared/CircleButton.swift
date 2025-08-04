import SwiftUI

struct CircleButton: View {
    let systemImage: String
    let background: AnyView
    let foreground: Color
    let borderColor: Color
    let action: () -> Void
    
    init(systemImage: String, background: Color, foreground: Color = .white, borderColor: Color = .clear, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.background = AnyView(background)
        self.foreground = foreground
        self.borderColor = borderColor
        self.action = action
    }
    
    init(systemImage: String, background: Material, foreground: Color = .white, borderColor: Color = .clear, action: @escaping () -> Void) {
        self.systemImage = systemImage
        self.background = AnyView(Rectangle().fill(background))
        self.foreground = foreground
        self.borderColor = borderColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .padding(12)
                .background(background)
                .clipShape(Circle())
                .overlay(Circle().stroke(borderColor, lineWidth: 2))
                .foregroundColor(foreground)
        }
    }
}

#Preview {
    VStack {
        CircleButton(systemImage: "plus", background: .accentColor, foreground: .white, borderColor: .black.opacity(0.1)) {}

        CircleButton(systemImage: "xmark", background: .white, foreground: .black, borderColor: .black.opacity(0.1)) {
        }
        
        CircleButton(systemImage: "arrow.up", background: .black, foreground: .white, borderColor: .black.opacity(0.1)) {
        }   
    }
}
