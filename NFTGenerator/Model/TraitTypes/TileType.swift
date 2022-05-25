//
//  TileType.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import Foundation

enum TileType: Int, CaseIterable {
    
    case
        topLeft, topInnerLeft, topInnerRight, topRight,
        innerTopLeft, innerTopInnerLeft, innerTopInnerRight, innerTopRight,
        innerBottomLeft, innerBottomInnerLeft, innerBottomInnerRight, innerBottomRight,
        bottomLeft, bottomInnerLeft, bottomInnerRight, bottomRight
}

extension TileType: Identifiable {
    var id: RawValue { rawValue }
}

extension TileType {
    
    var isEdgeTile: Bool {
        switch self {
        case .topLeft, .topInnerLeft, .topInnerRight, .topRight:
            return true
        case .bottomLeft, .bottomInnerLeft, .bottomInnerRight, .bottomRight:
            return true
        case .innerTopLeft, .innerTopRight, .innerBottomLeft, .innerBottomRight:
            return true
        default:
            return false
        }
    }
    
    static func fromInt16(_ int16: Int16) -> TileType {
        TileType(rawValue: Int(int16)) ?? .topLeft
    }
}

extension TileType: CustomStringConvertible {
    var description: String {
        switch self {
        case .topLeft: return "top left"
        case .topInnerLeft: return "top inner left"
        case .topInnerRight: return "top inner right"
        case .topRight:  return "top right"
        case .innerTopLeft: return "inner top left"
        case .innerTopInnerLeft: return "inner top inner left"
        case .innerTopInnerRight: return "inner top inner right"
        case .innerTopRight: return "inner top right"
        case .innerBottomLeft: return "inner bottom left"
        case .innerBottomInnerLeft: return "inner bottom inner left"
        case .innerBottomInnerRight: return "inner bottom inner right"
        case .innerBottomRight: return "inner bottom right"
        case .bottomLeft: return "bottom left"
        case .bottomInnerLeft: return "bottom inner left"
        case .bottomInnerRight: return "bottom inner right"
        case .bottomRight: return "bottom right"
        }
    }
}
