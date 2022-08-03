//
//  Strings.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 24/05/2022.
//

import Foundation

struct Strings {
    
    static let add = "Add"
    static let cancel = "Cancel"
    static let collection = "Collection"
    static let collections = "Collections"
    static let createWallet = "Create Wallet"
    static let creatingWallet = "Creating wallet ..."
    static let defaultCollectionSymbol = "COLL"
    static let deployConfirmation = "Deploy Confirmation"
    static let deployContract = "Deploy contract"
    static let deploying = "Deploying ..."
    static let doNotUseRealMoney = "Do not use real money!"
    static let enterStrongPassword = "Enter a strong password"
    static let error = "Error"
    static let etherscan = "Etherscan"
    static let generateImages = "Generate Images"
    static let generatePassword = "Generate password"
     static let generating = "Generating ..."
    static let mintMe = "Mint me"
    static let minting =  "Minting ..."
    static let name = "Name"
    static let nameColon = "Name:"
    static let newCollection = "New Collection"
    static let ok = "OK"
    static let opensea = "Opensea"
    static let passwordColon = "Password:"
    static let plus =  "plus"
    static let goerliColon = "Goerli: "
    static let setUpWallet = "Set up wallet"
    static let symbolColon = "Symbol:"
    static let success = "Success"
    static let uploadingImageToIpfs = "Uploading image to IFPS ..."
    static let uploadingTraitsToIpfs = "Uploading traits to IFPS ..."
    static let walletCreated = "Wallet Created!"
    
   
    
    static func deployConfirmation(name: String, symbol: String) -> String {
        "Are you sure you wish to deploy a contract with the name \"\(name)\" and the symbol \"\(symbol)\"?"
    }
    static func itemsWithCount(count: Int?) -> String {
        "Items: \(count ?? 0)"
    }
    static func mintedWithCount(count: Int) -> String {
        "Minted: \(count)"
    }
    static func symbolColonWithSymbol(symbol: String?) -> String {
        "Symbol: \(symbol ?? "")"
    }
    
    static func walletBalance(balance: String) -> String {
        "Wallet balance: \(balance) ETH"
    }
}
