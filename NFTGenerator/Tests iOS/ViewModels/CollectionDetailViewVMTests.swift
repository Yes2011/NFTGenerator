//
//  CollectionDetailViewVMTests.swift
//  NFTGeneratorTests
//
//  Created by Crispin Lingford on 21/04/2022.
//

import XCTest
import web3swift

@testable import NFTGenerator

class CollectionDetailViewVMTests: XCTestCase {

    var sut: CollectionDetailViewVM!
    var accountsService: AccountsService!

    @MainActor override func setUpWithError() throws {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        _ = try? nftCollectionStorage.addItem(name: "Derek and the Dominoes", symbol: "DDS")
        sut = CollectionDetailViewVM(nftCollectionStorage: nftCollectionStorage,
                                     collection: nftCollectionStorage.nftCollections.value[0])
        super.setUp()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    @MainActor func testGenerateCollectionItems() throws {

        let requestExpectation = expectation(description: "sut.generateCollectionItems should finish after creating and storing items")
        
        let collectionCount = 5000
        sut.nftCollectionStorage.nftCollections.value[0].contractAddress = "0x"
        try sut.nftCollectionStorage.save()
        Task {
            await sut.generateCollectionItems(maxItems: collectionCount)
            XCTAssertTrue(sut.collectionCount == collectionCount)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testDeploy() throws {
        
        let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        let contractService = ContractService(web3: web3)
        let accountsService = AccountsService(web3: web3)

        let requestExpectation = expectation(description: "sut.deploy should finish and update collection contract with contract address")

        Task {
           do {
               let allAddresses = try await accountsService.getAccounts()
               let nftCollection = sut.nftCollectionStorage.nftCollections.value.first
               XCTAssertNotNil(nftCollection)
               XCTAssertNil(nftCollection!.contractAddress)
               let result = try await sut.deploy(service: contractService, ethereumAddress: allAddresses[0], walletPassword: "")
               XCTAssertTrue(result)
               XCTAssertNotNil(nftCollection!.contractAddress)
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testDeployFailsIfHasExistingContract() throws {

        let requestExpectation = expectation(description: "sut.deploy should fail because there is an existing contract")

        Task {
           do {
               let nftCollection = sut.nftCollectionStorage.nftCollections.value.first
               XCTAssertNotNil(nftCollection)
               nftCollection!.contractAddress = "0x"
               let result = try await sut.deploy(service: nil, ethereumAddress: nil, walletPassword: "")
               XCTAssertFalse(result)
           } catch {
               XCTAssertNotNil(error)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testDeployFailsDueNilServiceOrAddress1() throws {

        let requestExpectation = expectation(description: "sut.deploy should fail because there is an existing contract")

        Task {
           do {
               let nftCollection = sut.nftCollectionStorage.nftCollections.value.first
               XCTAssertNotNil(nftCollection)
               let result = try await sut.deploy(service: nil, ethereumAddress: nil, walletPassword: "")
               XCTAssertFalse(result)
           } catch {
               XCTAssertNotNil(error)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testAddNFTCollection() throws {

        let requestExpectation = expectation(description: "sut.addNFTCollection should add a new collection")

        Task {
           do {
               let collectionsCount = sut.nftCollectionStorage.nftCollections.value.count
               _ = try sut.addNFTCollection(name: testName, symbol: testSymbol)
               let lastItem = sut.nftCollectionStorage.nftCollections.value.last
               XCTAssertNotNil(lastItem)
               XCTAssertEqual(lastItem!.name, testName)
               XCTAssertEqual(lastItem!.symbol, testSymbol)
               XCTAssertNotEqual(collectionsCount, sut.collectionCount)
            } catch {
                XCTFail(error.localizedDescription)
            }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testUpdateName() throws {

        let requestExpectation = expectation(description: "sut.updateName should update the collection's name")

        Task {
           let lastItem = sut.nftCollectionStorage.nftCollections.value.last
           XCTAssertNotNil(lastItem)
           XCTAssertNotEqual(lastItem!.name, testName)
           sut.updateName(newValue: testName)
           XCTAssertEqual(lastItem!.name, testName)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testUpdateSymbol() throws {

        let testSymbol = "NEW"
        let requestExpectation = expectation(description: "sut.updateSymbol should update the collection's symbol")

        Task {
           let lastItem = sut.nftCollectionStorage.nftCollections.value.last
           XCTAssertNotNil(lastItem)
           XCTAssertNotEqual(lastItem!.symbol, testSymbol)
           sut.updateSymbol(newValue: testSymbol)
           XCTAssertEqual(lastItem!.symbol, testSymbol)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testRemoveItems() {
        
        let requestExpectation = expectation(description: "sut.removeItems should remove all items from a collection")
        let collectionCount = 100

        Task {
            sut.nftCollectionStorage.nftCollections.value[0].contractAddress = "0x"
            try sut.nftCollectionStorage.save()
            await sut.generateCollectionItems(maxItems: collectionCount)
            XCTAssertTrue(collectionCount == sut.nftItemStorage.nftItems.value.count)
            sut.removeItems()
            XCTAssertTrue(sut.collectionCount == 0)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testgenerateCollectionItemsFails() {
        
        let requestExpectation = expectation(description: "sut.generateCollectionItems without parent should throw error")
        let collectionCount = 100

        Task {
            sut.nftCollectionStorage.nftCollections.value[0].contractAddress = "0x"
            sut.nftCollectionStorage.deleteCollection(collectionItem: sut.nftCollectionStorage.nftCollections.value[0])
            try? sut.nftCollectionStorage.save()
            await sut.generateCollectionItems(maxItems: collectionCount)
            XCTAssertTrue(sut.showError)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    @MainActor func testUpdateStorageFails() {
        
        let requestExpectation = expectation(description: "sut.updateCollectionStorage without collection should display erro")

        Task {
            sut.nftCollectionStorage.deleteCollection(collectionItem: sut.nftCollectionStorage.nftCollections.value[0])
            try? sut.nftCollectionStorage.save()
            sut.updateName(newValue: "new")
            sut.updateSymbol(newValue: "new")
            XCTAssertTrue(sut.showError)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
}
