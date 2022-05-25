//
//  WalletViewVM.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 16/04/2022.
//

import Combine
import Foundation
import SwiftUI
import web3swift

@MainActor
class WalletViewVM: ObservableObject {
    
    @Published var wallet: Wallet?
    
    init(wallet: Wallet? = Wallet.getFromUserDefaults) {
        self.wallet = wallet
    }
    
    func getBalance() async -> String {
        guard let wallet = wallet else { return "0.0" }
        let walletAddress = EthereumAddress(wallet.address)!
        do {
            let balanceResult = try await AccountsService().getBalance(address: walletAddress)
            return Web3.Utils.formatToEthereumUnits(balanceResult, toUnits: .eth, decimals: 2)!
        } catch {
            return error.localizedDescription
        }
    }
}
