//
//  NFTItemStorageTests.swift
//  Tests iOS
//
//  Created by YES 2011 Limited on 22/04/2022.
//

import XCTest
@testable import NFTGenerator

class NFTItemStorageTests: XCTestCase {
    
    var sut: NFTItemStorage!
    var parentStorage: NFTCollectionStorage!

    override func setUpWithError() throws {
        parentStorage = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        _ = try parentStorage.addItem(name: "Derek and the Dominoes", symbol: "DDS")
        sut = NFTItemStorage(persistenceController: parentStorage.persistenceController, parent: parentStorage.nftCollections.value[0])
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAddNftItem() throws {
        
        XCTAssertNoThrow(try sut.addItem(nft: NFTGenerator().randomNFT()))
        try sut.save()
        let nftItems = sut.nftItems.value
        XCTAssertNotNil(nftItems)
        XCTAssertTrue(nftItems.count == 1)
        XCTAssertTrue(nftItems[0].parent == parentStorage.nftCollections.value[0])
    }
}
