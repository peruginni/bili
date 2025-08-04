//
//  File.swift
//  
//
//  Created by Ondra on 28.05.2023.
//

import Foundation
import SwiftUI

extension Image {
    init(packageResource name: String, ofType type: String) {
#if canImport(UIKit)
        guard let path = Bundle.main.path(forResource: name, ofType: type),
//        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = UIImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(uiImage: image)
#elseif canImport(AppKit)
        guard let path = Bundle.module.path(forResource: name, ofType: type),
              let image = NSImage(contentsOfFile: path) else {
            self.init(name)
            return
        }
        self.init(nsImage: image)
#else
        self.init(name)
#endif
    }
}
