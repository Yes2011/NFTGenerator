//
//  ContractService.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Foundation
import PromiseKit
import web3swift

protocol ContractApi {
    var web3: web3 { get }
    func deploy(from: EthereumAddress, parameters: [AnyObject], password: String) async throws -> TransactionSendingResult?
}

struct ContractService: ContractApi {
    
    private(set) var web3: web3
    
    init(web3: web3 = Web3.InfuraRinkebyWeb3(), keystore: KeystoreManager? = nil) {
        self.web3 = web3
        if let keystore = keystore {
            self.web3.addKeystoreManager(keystore)
        }
    }
    
    func deploy(from: EthereumAddress, parameters: [AnyObject], password: String) async throws -> TransactionSendingResult? {
        let contract = web3.contract(ContractService.erc721ABIExtended, at: nil, abiVersion: 2)!
        let deployTx = contract.deploy(bytecode: ContractService.bytecode, parameters: parameters)!
        var options = TransactionOptions.defaultOptions
        options.from = from
        options.gasLimit = .manual(3000000)
        return try await withCheckedThrowingContinuation { continuation in
            deploy(deployTx: deployTx, password: password, options: options) { result, error in
                if let result = result {
                    continuation.resume(returning: result)
                }
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
             }
        }
    }
    
    func mint(from: EthereumAddress, at: EthereumAddress, tokenId: Int, tokenURI: String, password: String) async throws -> TransactionSendingResult? {
        
        var options = TransactionOptions.defaultOptions
        options.from = from
        options.gasLimit = .manual(3000000)

        guard let contract = web3.contract(ContractService.erc721ABIExtended, at: at, abiVersion: 2) else { return nil }
        let parameters: [AnyObject] = [tokenId, tokenURI] as [AnyObject]
        guard let writeTX = contract.method("createNFT", parameters: parameters, transactionOptions: options) else { return nil }
        return try await withCheckedThrowingContinuation { continuation in
            mint(writeTX: writeTX, password: password, options: options) { result, error in
                if let result = result {
                    continuation.resume(returning: result)
                }
                if let error = error {
                    continuation.resume(throwing: error)
                }
             }
        }
    }
    
    private func mint(writeTX: WriteTransaction,
                        password: String,
                        options: TransactionOptions? = nil,
                        completion: @escaping (TransactionSendingResult?, Error?) -> Void) {
                        
        DispatchQueue.global(qos: .userInitiated).async {
            let txPromise = writeTX.sendPromise(password: password, transactionOptions: options)
            do {
                let result = try txPromise.wait()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func fetchTransactionReceipt(txHash: String, attempts attemptsMax: Int = 100, interval retryInterval: Double = 3) async -> TransactionReceipt? {
        
        var tryCount = 1

        repeat {
            debugPrint("fetchTransactionReceipt attempt \(tryCount)")
            if let receipt = await fetchTransactionReceipt(txHash: txHash, delay: retryInterval) {
                return receipt
            }
            tryCount = tryCount + 1
        } while tryCount < attemptsMax
        return nil
    }

    
    private func fetchTransactionReceipt(txHash: String, delay: Double) async -> TransactionReceipt? {
        return await withCheckedContinuation { continuation in
            fetchTransactionReceipt(txHash: txHash, delay: delay) { result in
                continuation.resume(returning: result)
             }
        }
    }
    
    private func fetchTransactionReceipt(txHash: String, delay: Double = 0.0,
                        completion: @escaping (TransactionReceipt?) -> Void) {
                        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(wallDeadline: .now() + delay) {
            do {
                let receipt = try web3.eth.getTransactionReceipt(txHash)
                completion(receipt)
            } catch {
                completion(nil)
            }
        }
    }
    
    private func deploy(deployTx: WriteTransaction,
                        password: String,
                        options: TransactionOptions? = nil,
                        completion: @escaping (TransactionSendingResult?, Error?) -> Void) {
                        
        DispatchQueue.global(qos: .userInitiated).async {
            let txPromise = deployTx.sendPromise(password: password, transactionOptions: options)
            do {
                let result = try txPromise.wait()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}


extension web3.web3contract {

    func deploy(deployTx: WriteTransaction, password: String, completion: @escaping (TransactionSendingResult?, Error?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let txPromise = deployTx.sendPromise(password: password, transactionOptions: nil)
            do {
                let result = try txPromise.wait()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
}
