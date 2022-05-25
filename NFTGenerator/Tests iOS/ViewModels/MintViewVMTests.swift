//
//  MintViewVMTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 24/05/2022.
//

import Alamofire
import Mocker
import web3swift
import XCTest

@testable import NFTGenerator

class MintViewVMTests: XCTestCase {

    var sut: MintViewVM!
    var nftCollectionStorage: NFTCollectionStorage!
    var parent: NFTCollectionItem!
    
    override func setUpWithError() throws {
        nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController(inMemory: true))
        parent = try nftCollectionStorage.addItem(name: testName, symbol: testSymbol)
        let nftItemStorage = NFTItemStorage(persistenceController: nftCollectionStorage.persistenceController, parent: parent)
        try nftItemStorage.addItem(nft: NFT.fixture())
        try nftItemStorage.save()
        sut = MintViewVM(nftItem: nftItemStorage.nftItems.value.first!, nftItemStorage: nftItemStorage, wallet: nil)
    }

    override func tearDownWithError() throws {
    }

    func testPinFileToIPFS() throws {
        
        let imageFileName = "ethereum.png"
        let image = UIImage(named: imageFileName)
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let pinataService = PinataService(configuration: configuration)
        let apiEndpoint = URL(string: pinataService.pinataApiBase + "/\(PinataService.Endpoints.pinFileToIPFS)")!

        let requestExpectation = expectation(description: "pinFileToIPFS function call should return true")
        let expectedIPFSResponse = IPFSFilePinResponse(hash: "abc", size: 1, timestamp: "abc")

        let mockedData = try! JSONEncoder().encode(expectedIPFSResponse)
        let mock = Mock(url: apiEndpoint, dataType: .imagePNG, statusCode: 200, data: [.post: mockedData])
        mock.register()
        
        Task {
            let first = sut.nftItemStorage.nftItems.value.first!
            XCTAssertNil(first.ipfsImageHash)
            let result = await sut.pinFileToIPFS(uiImage: image, service: pinataService)
            XCTAssertTrue(result)
            XCTAssertNotNil(first.ipfsImageHash)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testPinFileToIPFSFailsDueToNilImage() throws {
        
        let requestExpectation = expectation(description: "pinFileToIPFS function call should return false")
        
        Task {
            let result = await sut.pinFileToIPFS(uiImage: nil)
            XCTAssertFalse(result)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testPinJSONToIPFS() throws {
        
        let imageFileName = "ethereum.png"
        let image = UIImage(named: imageFileName)
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        let pinataService = PinataService(configuration: configuration)
        let apiEndpoint = URL(string: pinataService.pinataApiBase + "/\(PinataService.Endpoints.pinFileToIPFS)")!

        let requestExpectation = expectation(description: "pinJSONToIPFS function call should return true")
        let expectedIPFSResponse = IPFSFilePinResponse(hash: "abc", size: 1, timestamp: "abc")

        let mockedData = try! JSONEncoder().encode(expectedIPFSResponse)
        let mock = Mock(url: apiEndpoint, dataType: .imagePNG, statusCode: 200, data: [.post: mockedData])
        mock.register()
        
        Task {
            let first = sut.nftItemStorage.nftItems.value.first!
            _ = await sut.pinFileToIPFS(uiImage: image, service: pinataService)
            XCTAssertNil(first.ipfsJSONHash)
            let result = await sut.pinJSONToIPFS(service: pinataService)
            XCTAssertTrue(result)
            XCTAssertNotNil(first.ipfsJSONHash)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testPinJSONToIPFSFailsDueToNilImageHash() throws {
        
        let requestExpectation = expectation(description: "pinJSONToIPFS function call should return false")
        
        Task {
            let result = await sut.pinJSONToIPFS()
            XCTAssertFalse(result)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testMint() throws {
        
        let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        let contractService = ContractService(web3: web3)
        let accountsService = AccountsService(web3: web3)

        let requestExpectation = expectation(description: "pinFileToIPFS function call should return true")

        Task {
            let first = sut.nftItemStorage.nftItems.value.first!
            first.ipfsJSONHash = "0x"
            parent.contractAddress = "0xEC08B4B5C0dC2AEA3fc1607b823749761528eA40"
            try nftCollectionStorage.save()
            let allAddresses = try await accountsService.getAccounts()
            let result = await sut.mint(service: contractService, address: allAddresses[0], password: "")
            XCTAssertFalse(result)
            XCTAssertNotNil(first.mintTransaction)
            XCTAssertTrue(first.isMinted)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }

}
