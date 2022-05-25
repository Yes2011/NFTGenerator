//
//  CollectionsViewVMTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 24/05/2022.
//

import XCTest

@testable import NFTGenerator

class CollectionsViewVMTests: XCTestCase {
    
    var sut: CollectionsViewVM!

    override func setUpWithError() throws {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        sut = CollectionsViewVM(nftCollectionStorage: nftCollectionStorage, wallet: nil)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddNFTCollection() throws {
        XCTAssertNil(sut.collections.first)
        sut.addNFTCollection(name: testName, symbol: testSymbol)
        XCTAssertNotNil(sut.collections.first)
        let first = sut.collections.first!
        XCTAssertNotNil(first.name)
        XCTAssertTrue(first.name! == testName)
        XCTAssertNotNil(first.symbol)
        XCTAssertTrue(first.symbol == testSymbol)
    }
    
    func testAddNFTCollectionFails() throws {
        XCTAssertNil(sut.collections.first)
        sut.addNFTCollection(name: "", symbol: "")
        XCTAssertTrue(sut.showError)
    }
    
    func testDeleteCollection()  {

        XCTAssertTrue(sut.collections.count == 0)
        sut.addNFTCollection(name: testName, symbol: testSymbol)
        XCTAssertTrue(sut.collections.count > 0)

        let indexSet = IndexSet(integer: 0)
        sut.deleteCollection(idxSet: indexSet)
        XCTAssertTrue(sut.collections.count == 0)
    }
    
    func testCollectionMintedCount() throws {
        
        sut.addNFTCollection(name: testName, symbol: testSymbol)
        let first = sut.collections.first!
        let itemStorage = NFTItemStorage(persistenceController: sut.nftCollectionStorage.persistenceController, parent: first)
        try itemStorage.addItem(nft: NFT.fixture())
        try itemStorage.save()
        XCTAssertTrue(sut.collectionMintedCount(collection: first) == 0)
        let firstChild = itemStorage.nftItems.value.first!
        firstChild.isMinted = true
        XCTAssertTrue(sut.collectionMintedCount(collection: first) > 0)
    }

}
