//
//  NFTCollection.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import Foundation

struct NFTCollection: Hashable {
    let id = UUID()
    var name: String
    var symbol: String
    var collectionType: CollectionType
    var contractAddress: String
}

extension NFTCollection {
    
    enum CollectionType: Int {
        case symbols = 0, botts = 1
    }

    static var fixture1: NFTCollection {
        NFTCollection(name: "Derek and the Dominoes",
                      symbol: "DEREK",
                      collectionType: CollectionType.symbols,
                      contractAddress: "0x")
    }
}
