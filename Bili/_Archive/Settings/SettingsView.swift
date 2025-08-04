//
//  File.swift
//  
//
//  Created by Ondra on 17.09.2023.
//

import Foundation
import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
    
    var body: some View {
        List {
            Section("General") {
                Toggle(isOn: .constant(true), label: {
                    Text("Ignore words with 3 and less letters")
                })
                HStack {
                    Text("Target language")
                    Spacer()
                    Image(systemName: "flag")
                }
            }
            
            Section("Other") {
                HStack {
                    Text("Send improvement idea")
                    Spacer()
                    Image(systemName: "mail")
                }
                HStack {
                    Text("Privacy policy")
                    Spacer()
                    Image(systemName: "mail")
                }
                HStack {
                    Text("Terms and conditions")
                    Spacer()
                    Image(systemName: "mail")
                }
            }
        }
    }
}

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsView()
        }
    }
}
