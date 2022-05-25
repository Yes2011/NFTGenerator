//
//  BackgroundColorType.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import Foundation
import SwiftUI

enum BackgroundColorType: Int, CaseIterable {
    case none, blue, orange, red, teal, yellow
}

extension BackgroundColorType {
    
    var color: Color {
        switch self {
        case .none: return Color.clear
        case .blue: return Color.blue
        case .orange: return Color.orange
        case .red: return Color.red
        case .teal: return Color.teal
        case .yellow: return Color.yellow
       }
    }
    
    static func fromInt16(_ int16: Int16) -> BackgroundColorType {
        BackgroundColorType(rawValue: Int(int16)) ?? .none
    }
}

extension BackgroundColorType: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: return "none"
        case .blue: return "blue"
        case .red: return "red"
        case .yellow: return "yellow"
        case .teal: return "teal"
        case .orange: return "orange"
        }
    }
}
