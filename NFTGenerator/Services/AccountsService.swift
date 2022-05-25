//
//  AccountsService.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 25/04/2022.
//

import BigInt
import Foundation
import PromiseKit
import web3swift



struct AccountsService {
    
    private(set) var web3: web3
    
    init(web3: web3 = Web3.InfuraRinkebyWeb3()) {
        self.web3 = web3
    }
    
    func getBalance(address: EthereumAddress, onBlock: String = "latest") async throws -> BigUInt {
        return try await withCheckedThrowingContinuation { continuation in
            getBalance(address: address, onBlock: onBlock) { result, error in
                if let result = result {
                    continuation.resume(returning: result)
                }
                if let error = error {
                    continuation.resume(throwing: error)
                }
             }
        }
    }
    
    private func getBalance(address: EthereumAddress, onBlock: String, completion: @escaping (BigUInt?, Error?) -> Void) {
                        
        DispatchQueue.global(qos: .userInitiated).async {
            let balancePromise = web3.eth.getBalancePromise(address: address, onBlock: onBlock)
            do {
                let result = try balancePromise.wait()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
    
    func getAccounts() async throws -> [EthereumAddress] {
        return try await withCheckedThrowingContinuation { continuation in
            getAccounts() { result, error in
                if let result = result {
                    continuation.resume(returning: result)
                }
                if let error = error {
                    continuation.resume(throwing: error)
                }
                
             }
        }
    }
    
    private func getAccounts(completion: @escaping ([EthereumAddress]?, Error?) -> Void) {
                        
        DispatchQueue.global(qos: .userInitiated).async {
            let accountsPromise = web3.eth.getAccountsPromise()
            do {
                let result = try accountsPromise.wait()
                completion(result, nil)
            } catch {
                completion(nil, error)
            }
        }
    }
}
