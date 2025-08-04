import Foundation
import ComposableArchitecture
import SwiftUI

struct TextInputView: View {
    let placeholder: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var text: String
    @State private var dynamicHeight: CGFloat = 40
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused(isFocused)
                .scrollContentBackground(.hidden)
                .background(Color.white)
                .frame(height: dynamicHeight)
                .onChange(of: text) {
                    recalculateHeight()
                }
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    /// Dynamically recalculates the height of the `TextEditor`
    private func recalculateHeight() {
        let newHeight = min(150, max(40, estimateTextHeight()))
        if newHeight != dynamicHeight {
            dynamicHeight = newHeight
        }
    }

    /// Estimates text height based on character count (adjust as needed)
    private func estimateTextHeight() -> CGFloat {
        let lineHeight: CGFloat = 23
        let lines = max(1, text.split(separator: "\n").count + 1 )
        return CGFloat(lines) * lineHeight + 10
    }
}

#Preview {
    struct PreviewContainer: View {
        @FocusState var isTextFocused: Bool
        @State var previewText = ""
        var body: some View {
            VStack {
                Spacer()
                TextInputView(
                    placeholder: "Write german text to translate...",
                    isFocused: $isTextFocused,
                    text: $previewText
                )
            }
            .background(.red)
        }
    }
    return PreviewContainer()
}
