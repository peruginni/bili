//
//  File.swift
//  
//
//  Created by Ondra on 18.05.2023.
//

import Foundation
import SwiftUI

struct SnapsCellView: View {
    let title: String?
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        VStack(spacing: 4) {
            if let title {
                Text(title)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 10)
        .background(colorScheme == .dark ? Color.init(white: 0.15) : Color.init(white: 0.95))
        .cornerRadius(5)
    }
}

struct SnapsCellView_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            SnapsCellView(
                title: "Test"
            )
            .environment(\.colorScheme, .dark)
            
            
            SnapsCellView(
                title: "Test"
            )
            .environment(\.colorScheme, .dark)
            
            SnapsCellView(
                title: "Test"
            )
            .environment(\.colorScheme, .light)
            
            SnapsCellView(
                title: nil
            )
            .environment(\.colorScheme, .light)
        }
    }
}

private let lipsumText = "Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Nullam dapibus fermentum ipsum. Nam quis nulla. Nullam rhoncus aliquam metus. Nulla est. Aenean fermentum risus id tortor. Duis risus. Nullam dapibus fermentum ipsum. Fusce suscipit libero eget elit. Aenean vel massa quis mauris vehicula lacinia. Morbi leo mi, nonummy eget tristique non, rhoncus non leo"

