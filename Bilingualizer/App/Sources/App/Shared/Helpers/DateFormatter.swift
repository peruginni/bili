//
//  File.swift
//  
//
//  Created by Ondra on 04.06.2023.
//

import Foundation

let sharedDateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()
