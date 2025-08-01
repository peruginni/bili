//
//  Screen.swift
//  App
//
//  Created by Ondra on 28.03.2025.
//

import UIKit

func getScreenNativeWidth() -> CGFloat {
    guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
          let window = scene.windows.first
    else { return 0 }
    
    return window.screen.nativeBounds.width
}
