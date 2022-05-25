//
//  NFTGenerator.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 22/04/2022.
//

import Foundation
import SFSymbols

struct NFTGenerator {
    
    var allSymbols = SFSymbol.allSymbols
    
    var randomSymbol: SFSymbol {
        allSymbols[Int.random(in: 0..<allSymbols.count)]
    }
    
    var randomRotation: RotationType {
        RotationType(rawValue: Int.random(in: 0..<RotationType.allCases.count)) ?? .degrees_0
    }
    
    var randomBorder: BorderType {
        BorderType(rawValue: Int.random(in: 0..<BorderType.allCases.count)) ?? .none
    }
    
    var randomColor: BackgroundColorType {
        BackgroundColorType(rawValue: Int.random(in: 0..<BackgroundColorType.allCases.count)) ?? .none
    }
    
    var randomCollectionColor: BackgroundColorType {
        BackgroundColorType(rawValue: Int.random(in: 1..<BackgroundColorType.allCases.count)) ?? .none
    }
    
    var randomTileSlot: TileType {
        let edgeTiles = TileType.allCases.filter { tileType in
            tileType.isEdgeTile == true
        }
        return edgeTiles[Int.random(in: 0..<edgeTiles.count)]
    }
    
    func randomNFT(generatedIdx: Int = 1) -> NFT {
        return NFT(
            id: UUID(), generatedIdx: generatedIdx, primarySymbol: randomSymbol.title,
            primaryRotationType: randomRotation,
            primaryBackgroundColor: randomColor,
            primaryBorderType: randomBorder,
            secondarySymbol: randomSymbol.title,
            secondaryRotation: randomRotation,
            secondaryBackgroundColor: randomColor,
            secondaryBorderType: randomBorder,
            secondaryTileSlot: randomTileSlot
        )
    }
}
