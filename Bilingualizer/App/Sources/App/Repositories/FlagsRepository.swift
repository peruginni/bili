//
//  File.swift
//  
//
//  Created by Ondra on 01.08.2023.
//

import Foundation

class FlagsRepository {
    
//    var launchNumber: Bool {
//        get {
//            UserDefaults.standard.bool(forKey: "isFirstTimeLaunch")
//        }
//        set {
//            UserDefaults.standard.set(newValue, forKey: "isFirstTimeLaunch")
//        }
//    }
    
    var isSimulator: Bool {
        #if TARGET_OS_SIMULATOR
        return true
        #else
        return false
        #endif
    }
}
