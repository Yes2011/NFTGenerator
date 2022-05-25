//
//  CollectionViewVMTest.swift
//  Tests iOS
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import XCTest

@testable import NFTGenerator

class CollectionViewVMTests: XCTestCase {

    var sut: CollectionsViewVM!

    override func setUp() {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        sut = CollectionsViewVM(nftCollectionStorage: nftCollectionStorage)
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testCollectionsPublisherUpdatedWhenAfterCallingAddNFTCollection() throws {
        
        XCTAssertTrue(sut.collections.count == 0)
        sut.addNFTCollection(name: testName, symbol: testSymbol)

        let updateExpectation = expectation(description: "collections publisher value should newly include item when this is added to nftCollectionStorage")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.collections.count, 1)
            XCTAssertEqual(self.sut.collections[0].name, self.testName)
            XCTAssertEqual(self.sut.collections[0].symbol, self.testSymbol)
            updateExpectation.fulfill()
        }
        wait(for: [updateExpectation], timeout: 1.0)
    }
}
