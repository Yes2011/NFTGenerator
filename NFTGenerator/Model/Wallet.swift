//
//  Wallet.swift
//  NFTGenerator (iOS)
//
//  Created by Crispin Lingford on 19/04/2022.
//

import Foundation
import Keychain

struct Wallet: Codable {
    let address: String
    let data: Data
    let name: String
    let isHD: Bool
}

struct HDKey {
    let name: String?
    let address: String
}

extension Wallet {
    
    var keychain: Keychain {
        Keychain()
    }
    
    func savePwdToKeychain(password: String) -> Bool {
        keychain.save(password, forKey: WalletKeys.walletPassword)
    }
    
    var pwdFromKeychain: String {
        guard let pwd = keychain.value(forKey: WalletKeys.walletPassword) as? String else { return "" }
        return pwd
    }
    
    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(encoded, forKey: WalletKeys.wallet)
        }
    }
    
    static var getFromUserDefaults: Wallet? {
        guard let data = UserDefaults.standard.value(forKey: WalletKeys.wallet) as? Data else { return nil }
        return try? JSONDecoder().decode(Wallet.self, from: data)
    }
    
    static var previewWallet: Wallet {
        Wallet(address: "0x0cd85c293cD0c576005A4543C3b0fD1940d96DCa", data: Data(), name: "Super Wallet", isHD: false)
    }

}
