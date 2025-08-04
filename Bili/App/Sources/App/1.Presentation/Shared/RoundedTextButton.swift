//
//  RoundedTextButton.swift
//  App
//
//  Created by Ondra on 01.04.2025.
//


import SwiftUI

struct RoundedTextButton: View {
    let text: String
    let background: Color
    let foreground: Color
    let borderColor: Color
    let action: () -> Void
    
    init(text: String, background: Color, foreground: Color = .white, borderColor: Color = .clear, action: @escaping () -> Void) {
        self.text = text
        self.background = background
        self.foreground = foreground
        self.borderColor = borderColor
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(foreground)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(background)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(borderColor, lineWidth: 2)
                )
        }
    }
}

#Preview {
    VStack {
        RoundedTextButton(text: "Longer button", background: .clear, foreground: .black, borderColor: .black.opacity(0.2)) {
            
        }
        RoundedTextButton(text: "OK", background: .blue, foreground: .white, borderColor: .white.opacity(0.5)) {
            
        }
        
        RoundedTextButton(text: "Go", background: .green, foreground: .white, borderColor: .black.opacity(0.1)) {
            
        }   
    }
}
