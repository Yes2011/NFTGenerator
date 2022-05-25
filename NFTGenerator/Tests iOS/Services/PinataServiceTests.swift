//
//  PinataServiceTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Alamofire
import Mocker
import XCTest
@testable import NFTGenerator

class PinataServiceTests: XCTestCase {
    
    var sut: PinataService!

    override func setUpWithError() throws {
        let configuration = URLSessionConfiguration.af.default
        configuration.protocolClasses = [MockingURLProtocol.self]
        self.sut = PinataService(configuration: configuration)
        super.setUp()
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }

    func testPinFile() throws {

        let imageFileName = "ethereum.png"
        let imageData = UIImage(named: imageFileName)!.jpegData(compressionQuality: 0.7)!
        let apiEndpoint = URL(string: sut.pinataApiBase + "/\(PinataService.Endpoints.pinFileToIPFS)")!

        let expectedIPFSResponse = IPFSFilePinResponse(hash: "abc", size: 1, timestamp: "abc")
        let requestExpectation = expectation(description: "Request should finish and return valid json")

        let mockedData = try! JSONEncoder().encode(expectedIPFSResponse)
        let mock = Mock(url: apiEndpoint, dataType: .imagePNG, statusCode: 200, data: [.post: mockedData])
        mock.register()
        
        Task {
           do {
               let result = try await sut.pinFile(data: imageData, fileName: imageFileName)
               XCTAssertNotNil(result)
               XCTAssertEqual(result!, expectedIPFSResponse)
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
}
