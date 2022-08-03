//
//  NFTTraitTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import XCTest
@testable import NFTGenerator

class NFTTraitTests: XCTestCase {

    var sut: NFTTrait!
    var randomNFT: NFT!

    override func setUp() {
        randomNFT = NFTGenerator().randomNFT()
        sut = NFTTrait(nft: randomNFT, ipfsHash: "0x", fileName: "7922-Iggy and the pops")
        super.setUp()
    }

    override func tearDown()  {
        sut = nil
    }
    
    func testSutEncodesCorrectly() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        let data = try encoder.encode(sut)
        XCTAssertNotNil(data)
        debugPrint(data.prettyJson!)
        let decoded = try JSONDecoder().decode(NFTTrait.self, from: data)
        XCTAssertTrue(decoded.isEqual(with: randomNFT))
        debugPrint(decoded)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}


extension NFTTrait {
    
    func isEqual(with nft: NFT) -> Bool {
        self.attributes[0].value == nft.primarySymbol &&
        self.attributes[1].value == nft.primaryBorderType.description &&
        self.attributes[2].value == nft.primaryRotationType.description &&
        self.attributes[3].value == nft.primaryBackgroundColor.description &&
        self.attributes[4].value == nft.secondarySymbol &&
        self.attributes[5].value == nft.secondaryBorderType.description &&
        self.attributes[6].value == nft.secondaryRotation.description &&
        self.attributes[7].value == nft.secondaryBackgroundColor.description &&
        self.attributes[8].value == nft.secondaryTileSlot.description
    }
}

extension Data {
    var prettyJson: String? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = String(data: data, encoding:.utf8) else { return nil }

        return prettyPrintedString
    }
}
