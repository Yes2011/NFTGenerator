//
//  TestNFTCollectionStorage.swift
//  Tests iOS
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import XCTest
@testable import NFTGenerator

class TestNFTCollectionStorage: XCTestCase {

    var sut: NFTCollectionStorage!

    override func setUp() {
        sut = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testAddNftCollection() throws {
        let name = "Name"
        let symbol = "Symbol"
        XCTAssertNoThrow(try sut.addItem(name: name, symbol: symbol))
        let nftCollections = sut.nftCollections.value
        XCTAssertNotNil(nftCollections)
        XCTAssertTrue(nftCollections[0].name == name)
        XCTAssertTrue(nftCollections[0].symbol == symbol)
    }
    
    func testAddNftCollectionWithTooShortName() {
        let name = "T"
        let symbol = "Symbol"
        XCTAssertThrowsError(try sut.addItem(name: name, symbol: symbol))
    }
    
    func testAddNftCollectionWithTooShortSymbol() {
        let name = "Name"
        let symbol = "T"
        XCTAssertThrowsError(try sut.addItem(name: name, symbol: symbol))
    }
}
