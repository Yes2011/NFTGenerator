//
//  NFTTrait.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 06/04/2022.
//

import Foundation
import SwiftUI
import SFSymbols

extension RawRepresentable where RawValue == Int {
    var int16: Int16 {
        return Int16(rawValue)
    }
}

struct NFT: Equatable, Hashable {
    
    var id: UUID
    var generatedIdx: Int
    var primarySymbol: String
    var primaryRotationType: RotationType
    var primaryBackgroundColor: BackgroundColorType
    var primaryBorderType: BorderType
    var secondarySymbol: String
    var secondaryRotation: RotationType
    var secondaryBackgroundColor: BackgroundColorType
    var secondaryBorderType: BorderType
    var secondaryTileSlot: TileType
    
    static let primarySymbolKey = "Primary Symbol"
    static let primaryRotationTypeKey = "Primary Rotation"
    static let primaryBackgroundColorKey = "Primary Background"
    static let primaryBorderTypeKey = "Primary Border"
    static let secondarySymbolKey = "Secondary Symbol"
    static let secondaryRotationKey = "Secondary Rotation"
    static let secondaryBackgroundColorKey = "Secondary Background"
    static let secondaryBorderTypeKey = "Secondary Border"
    static let secondaryTileSlotKey = "Secondary Tile Position"
}

extension NFT {
    
    static func fixture() -> NFT {
        NFT(id: UUID(), generatedIdx: 11, primarySymbol: "plus",
                 primaryRotationType: .degrees_45,
                 primaryBackgroundColor: .red,
                 primaryBorderType: .solid,
                 secondarySymbol: "character.bubble.fill.ar",
                 secondaryRotation: .degrees_135,
                 secondaryBackgroundColor: .yellow,
                 secondaryBorderType: .solid,
                 secondaryTileSlot: .bottomInnerLeft)
    }
    
    static func fromStorageItem(item: NFTItem) -> NFT {
        NFT(id: item.id!,
            generatedIdx: Int(item.generatedIdx),
            primarySymbol: item.primarySymbol ?? "plus",
            primaryRotationType: RotationType.fromInt16(item.primaryRotationTypeValue),
            primaryBackgroundColor: BackgroundColorType.fromInt16(item.primaryBackgroundColorValue),
            primaryBorderType: BorderType.fromInt16(item.primaryBorderTypeValue),
            secondarySymbol: item.secondarySymbol ?? "plus",
            secondaryRotation: RotationType.fromInt16(item.secondaryRotationValue),
            secondaryBackgroundColor: BackgroundColorType.fromInt16(item.secondaryBackgroundColorValue),
            secondaryBorderType: BorderType.fromInt16(item.secondaryBorderTypeValue),
            secondaryTileSlot: TileType.fromInt16(item.secondaryTileSlotValue))
    }
    
}
