//
//  CreateWalletViewVMTests.swift
//  Tests iOS
//
//  Created by YES 2011 Limited on 24/05/2022.
//

import XCTest

@testable import NFTGenerator

class CreateWalletViewVMTests: XCTestCase {

    var sut: CreateWalletViewVM!

    override func setUpWithError() throws {
        sut = CreateWalletViewVM()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testValidatePasswordFailsForOnlyNumbers() {
        
        let result = sut.validatePassword(password: "123456789101112")
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }
    
    func testValidatePasswordFailsForOnlyLetters() {
        
        let result = sut.validatePassword(password: "abcdefghijkl")
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }
    
    func testValidatePasswordFailsForTooShort() {
        
        let result = sut.validatePassword(password: "abC1234$")
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }
    
    func testValidatePasswordFailsForNoCapitals() {
        
        let result = sut.validatePassword(password: "abc1234$6789012")
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }
    
    func testValidatePasswordFailsForNoSpacialChars() {
        
        let result = sut.validatePassword(password: "abc1234LP6789012")
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }
    
    func testValidatePasswordSucceeds() {
        
        let result = sut.validatePassword(password: "abc1234LP$6789012")
        XCTAssertTrue(result)
        XCTAssertFalse(sut.showError)
    }
    
    func testGeneratePassword() {
        
        let result = sut.generatePassword()
        XCTAssertTrue(result.count == 16)
    }
    
    func testCreateWallet() throws {

        let requestExpectation = expectation(description: "sut.createWallet should succeed")

        Task {
            XCTAssertFalse(sut.isWalletCreated)
            await sut.createWallet(password: sut.generatePassword())
            XCTAssertTrue(sut.isWalletCreated)
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
