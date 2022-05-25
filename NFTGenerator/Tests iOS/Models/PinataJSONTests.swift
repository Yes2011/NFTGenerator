//
//  PinataJSONTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 26/04/2022.
//

import XCTest
@testable import NFTGenerator

class PinataJSONTests: XCTestCase {
    
    var sut: PinataJSON!
    var randomNFT: NFT!

    override func setUpWithError() throws {
        randomNFT = NFTGenerator().randomNFT()
        let nftTrait = NFTTrait(nft: randomNFT, ifpsHash: "0x", fileName: "7922-Iggy and the pops")
        sut = PinataJSON(pinataMetadata: PinataMetadata(name: "122-Iggy and the pops.png"), pinataContent: nftTrait)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSutEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let data = try encoder.encode(sut)
        XCTAssertNotNil(data)
        debugPrint(data.prettyJson!)
        let decoded = try JSONDecoder().decode(PinataJSON.self, from: data)
        debugPrint(decoded)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
