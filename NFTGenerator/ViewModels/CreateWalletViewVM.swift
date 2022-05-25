//
//  CreateWalletViewVM.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 16/04/2022.
//

import Combine
import Foundation
import SwiftUI
import web3swift

class CreateWalletViewVM: ObservableObject {
    
    @Published var showError: Bool = false
    @Published var isWalletCreated: Bool = false
    @Published var isWalletCreateInProgress: Bool = false
    private(set) var errorMessage: String = ""
    var passwordMinLength = 12
    
    init(passwordMinLength: Int = 12) {
        self.passwordMinLength = passwordMinLength
    }
    
    func createWallet(password: String) async {
        await withCheckedContinuation { continuation in
            createWallet(password: password) {
                continuation.resume()
             }
        }
    }

    func createWallet(password: String, completion: @escaping () -> Void) {
        isWalletCreateInProgress = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let keystore = try! EthereumKeystoreV3(password: password)!
            let name = "NFTGeneratorWallet"
            let keyData = try! JSONEncoder().encode(keystore.keystoreParams)
            let address = keystore.addresses!.first!.address
            let wallet = Wallet(address: address, data: keyData, name: name, isHD: false)
            _ = wallet.savePwdToKeychain(password: password)
            debugPrint(wallet)
            wallet.saveToUserDefaults()
            self.isWalletCreateInProgress = false
            self.isWalletCreated = true
            completion()
        }
    }

    func validatePassword(password: String) -> Bool {
        if password.count < passwordMinLength || !PasswordBuilder().allAttributeCharsPresent(for: password, attributes: passwordAttributes) {
            errorMessage = "The password should be 12 or more characters and include numbers, upper and lower case letters and special characters"
            showError = true
            return false
        }
        return true
    }
    
    func generatePassword() -> String {
        return PasswordBuilder().build(with: passwordAttributes, length: 16)
    }
}

extension CreateWalletViewVM {
    
    var passwordAttributes: [PasswordAttribute] {
        [.numbers, .symbols, .lowercaseLetters, .uppercaseLetters]
    }
}
