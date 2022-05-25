//
//  NFTTrait.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 23/04/2022.
//

import Foundation

struct NFTTrait: Codable {

    let description: String
    let image: String
    let name: String
    var attributes: [NFTAttribute] = []
    
    init(nft: NFT, ifpsHash: String, fileName: String) {
        self.description = "A random image created by Yes 2011 Limited"
        self.name = "A random name from Yes 2011's magical lexicon"
        self.image = "ipfs://\(ifpsHash)"
        self.attributes = createAttributes(nft: nft)
    }
    
    private func createAttributes(nft: NFT) -> [NFTAttribute] {
        var attributes: [NFTAttribute] = []
        attributes.append(NFTAttribute(trait_type: NFT.primarySymbolKey, value: nft.primarySymbol))
        attributes.append(NFTAttribute(trait_type: NFT.primaryBorderTypeKey, value: nft.primaryBorderType.description))
        attributes.append(NFTAttribute(trait_type: NFT.primaryRotationTypeKey, value: nft.primaryRotationType.description))
        attributes.append(NFTAttribute(trait_type: NFT.primaryBackgroundColorKey, value: nft.primaryBackgroundColor.description))
        attributes.append(NFTAttribute(trait_type: NFT.secondarySymbolKey, value: nft.secondarySymbol))
        attributes.append(NFTAttribute(trait_type: NFT.secondaryBorderTypeKey, value: nft.secondaryBorderType.description))
        attributes.append(NFTAttribute(trait_type: NFT.secondaryRotationKey, value: nft.secondaryRotation.description))
        attributes.append(NFTAttribute(trait_type: NFT.secondaryBackgroundColorKey, value: nft.secondaryBackgroundColor.description))
        attributes.append(NFTAttribute(trait_type: NFT.secondaryTileSlotKey, value: nft.secondaryTileSlot.description))
        return attributes
    }
}

//"description": "Friendly OpenSea Creature",
//"image": "https://opensea-prod.appspot.com/puffs/3.png",
//"name": "Dave Starbelly",
//"attributes": [
//    { "trait_type": "Base", "value": "Starfish" },
//    { "trait_type": "Eyes", "value": "Big" },
//    { "trait_type": "Mouth","value": "Surprised" },
//]

struct NFTAttribute: Codable {
    let trait_type: String
    let value: String
}
