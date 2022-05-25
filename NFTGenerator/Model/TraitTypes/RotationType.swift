//
//  RotationType.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import Foundation

enum RotationType: Int, CaseIterable {
    case degrees_0 = 0
    case degrees_45 = 45
    case degrees_90 = 90
    case degrees_135 = 135
    case degrees_180 = 180
}

extension RotationType {
    
    static func fromInt16(_ int16: Int16) -> RotationType {
        RotationType(rawValue: Int(int16)) ?? .degrees_0
    }
}

extension RotationType: CustomStringConvertible {
    var description: String {
        switch self {
        case .degrees_0: return "0 degrees"
        case .degrees_45: return "45 degrees"
        case .degrees_90: return "90 degrees"
        case .degrees_135: return "135 degrees"
        case .degrees_180: return "180 degrees"
        }
    }
}
