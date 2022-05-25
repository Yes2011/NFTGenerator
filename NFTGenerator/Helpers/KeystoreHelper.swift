//
//  KeystoreManager.swift
//  NFTGenerator (iOS)
//
//  Created by Crispin Lingford on 19/04/2022.
//

import Foundation
import web3swift

struct KeystoreHelper {
    
    static func getKeystoreManager(wallet: Wallet) -> KeystoreManager {
        let data = wallet.data
        let keystoreManager: KeystoreManager
        if wallet.isHD {
            let keystore = BIP32Keystore(data)!
            keystoreManager = KeystoreManager([keystore])
        } else {
            let keystore = EthereumKeystoreV3(data)!
            keystoreManager = KeystoreManager([keystore])
        }
        return keystoreManager
    }
}
