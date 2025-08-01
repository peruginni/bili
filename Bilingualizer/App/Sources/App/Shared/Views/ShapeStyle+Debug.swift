//
//  DebugView.swift
//  App
//
//  Created by Ondra on 26.02.2025.
//
import SwiftUI

public extension ShapeStyle where Self == Color {
    static var debug: Color {
#if DEBUG
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
#else
        return Color(.clear)
#endif
    }
}
