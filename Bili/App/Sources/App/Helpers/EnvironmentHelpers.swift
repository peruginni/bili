//
//  EnvironmentHelpers.swift
//  App
//
//  Created by Ondra on 03.08.2025.
//


import Foundation

enum EnvironmentHelpers {
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
