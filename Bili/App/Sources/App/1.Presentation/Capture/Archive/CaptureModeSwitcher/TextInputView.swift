import Foundation
import ComposableArchitecture
import SwiftUI

struct TextInputView: View {
    let placeholder: String
    var isFocused: FocusState<Bool>.Binding
    @Binding var text: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused(isFocused)
                .scrollContentBackground(.hidden)
                .frame(height: CameraClientConstant.captureHeight - 90)
            
            
            if text.isEmpty, !isFocused.wrappedValue {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
            }
        }
        .frame(maxWidth: .infinity)
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
