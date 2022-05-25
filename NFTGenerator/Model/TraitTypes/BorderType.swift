//
//  BorderType.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import Foundation

enum BorderType: Int, CaseIterable {
    case none, solid, semiDotted, dotted
}

extension BorderType {
    
    static func fromInt16(_ int16: Int16) -> BorderType {
        BorderType(rawValue: Int(int16)) ?? .none
    }
}

extension BorderType: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: return "none"
        case .solid: return "solid"
        case .semiDotted: return "semi-dotted"
        case .dotted: return "dotted"
        }
    }
}
