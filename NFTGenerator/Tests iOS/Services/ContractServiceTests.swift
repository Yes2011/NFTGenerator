//
//  ContractServiceTests.swift
//  NFTGeneratorTests
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import BigInt
import XCTest
import web3swift
@testable import NFTGenerator

class ContractServiceTests: XCTestCase {

    var sut: ContractService!
    var accountsService: AccountsService!
    
    override func setUpWithError() throws {
        let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        sut = ContractService(web3: web3)
        accountsService = AccountsService(web3: web3)
        super.setUp()
    }

    override func tearDownWithError() throws {
        sut = nil
        super.tearDown()
    }
    
    var parameters = [
        "Iggy Pop",
        "IGGY"
    ] as [AnyObject]

    func testDeployContract() throws {
        
        let requestExpectation = expectation(description: "sut.deploy should finish and return valid TransactionSendingResult ")

        Task {
           do {
               let allAddresses = try await accountsService.getAccounts()
               let result = try await sut.deploy(from: allAddresses[0], parameters: parameters, password: "web3Swift")

               XCTAssertNotNil(result)
               print(result!)
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testUserCase1() throws {
        let (web3, _, receipt, abiString) = try web3swiftHelpers.localDeployERC721()
        let account = EthereumAddress("0xe22b8979739D724343bd002F9f432F5990879901")!
        let contract = web3.contract(abiString, at: receipt.contractAddress!)!
        let readTransaction = contract.read("name")!
        readTransaction.transactionOptions.from = account
        let response = try readTransaction.callPromise().wait()
        print(response)
    }
    
    func testMint() throws {
        
        let requestExpectation = expectation(description: "sut.mint should finish and return valid TransactionSendingResult ")
        Task {
           do {
               let allAddresses = try await accountsService.getAccounts()
               let contractAddress = EthereumAddress("0xEC08B4B5C0dC2AEA3fc1607b823749761528eA40")!
               let tokenURI = "ipfs://Qmabc/example.json"
               let mintTx = try await sut.mint(from: allAddresses[0], at: contractAddress, tokenId: 1, tokenURI: tokenURI, password: "web3Swift")
               XCTAssertNotNil(mintTx)
               print(mintTx!)
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testFetchTransactionReceiptAfterDeployment() throws {

        let requestExpectation = expectation(description: "sut.fetchTransactionReceipt should finish and return valid transaction receipt")

        Task {
           do {
               let allAddresses = try await accountsService.getAccounts()
               let deployTx = try await sut.deploy(from: allAddresses[0], parameters: parameters, password: "web3Swift")
               XCTAssertNotNil(deployTx)
               print(deployTx!)
               let receipt = await sut.fetchTransactionReceipt(txHash: deployTx!.hash, interval: 0.0)
               XCTAssertNotNil(receipt)
               print(receipt!)
               XCTAssert(receipt!.contractAddress != nil)

               switch receipt!.status {
               case .notYetProcessed:
                   XCTAssertTrue(false)
               default:
                   break
               }
               let details = try sut.web3.eth.getTransactionDetails(receipt!.transactionHash)
               print(details)
               XCTAssert(details.transaction.to == .contractDeploymentAddress())
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)
    }
    
    func testFetchTransactionReceiptAfterMint() throws {

        let requestExpectation = expectation(description: "sut.fetchTransactionReceipt should finish and return valid transaction receipt")

        Task {
           do {
               let allAddresses = try await accountsService.getAccounts()
               let contractAddress = EthereumAddress("0xB0bE2058f72649B7E336c7Fd39C63e1762c13f29")!
               let tokenURI = "ipfs://Qmabc/example.json"
               let mintTx = try await sut.mint(from: allAddresses[0], at: contractAddress, tokenId: 1, tokenURI: tokenURI, password: "web3Swift")
               XCTAssertNotNil(mintTx)
               print(mintTx!)
               let receipt = await sut.fetchTransactionReceipt(txHash: mintTx!.hash, interval: 0.0)
               XCTAssertNotNil(receipt)
               print(receipt!)

               switch receipt!.status {
               case .notYetProcessed:
                   XCTAssertTrue(false)
               default:
                   break
               }
               let details = try sut.web3.eth.getTransactionDetails(receipt!.transactionHash)
               print(details)
           } catch {
               XCTFail(error.localizedDescription)
           }
            requestExpectation.fulfill()
        }
        wait(for: [requestExpectation], timeout: 10.0)

    }

    func testFetchTransactionReceiptIwthInvalidHash() throws {

        let requestExpectation = expectation(description: "sut.fetchTransactionReceipt should finish without returning transaction receipt")

        Task {
            let receipt = await sut.fetchTransactionReceipt(txHash: "Ox123", attempts: 10, interval: 0.0)
            XCTAssertNil(receipt)
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


//
//  web3swiftHelpers.swift
//  Tests
//
//  Created by Anton Grigorev on 30.07.2021.
//  Copyright © 2021 Anton Grigorev. All rights reserved.
//

import Foundation
import BigInt

import web3swift

class web3swiftHelpers {
    static func localDeployERC721() throws -> (web3, TransactionSendingResult, TransactionReceipt, String) {
        let abiString = ContractService.erc721ABIExtended
        let bytecode = ContractService.bytecode
        
        let web3 = try Web3.new(URL.init(string: "http://127.0.0.1:8545")!)
        let allAddresses = try web3.eth.getAccounts()
        let contract = web3.contract(abiString, at: nil, abiVersion: 2)!
        
        let parameters = [
            "Iggy Pop",
            "IGGY"
        ] as [AnyObject]
        let deployTx = contract.deploy(bytecode: bytecode, parameters: parameters)!
        deployTx.transactionOptions.from = allAddresses[0]
        deployTx.transactionOptions.gasLimit = .manual(3000000)
        let result = try deployTx.sendPromise().wait()
        let txHash = result.hash
        print("Transaction with hash " + txHash)
        
        Thread.sleep(forTimeInterval: 1.0)
        
        let receipt = try web3.eth.getTransactionReceipt(txHash)
        print(receipt)
        
        switch receipt.status {
        case .notYetProcessed:
            throw Web3Error.processingError(desc: "Transaction is unprocessed")
        default:
            break
        }
        
        return (web3, result, receipt, abiString)
    }
}
