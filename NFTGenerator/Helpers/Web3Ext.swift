//
//  Web3Ext.swift
//  NFTGenerator (iOS)
//
//  Created by Crispin Lingford on 03/08/2022.
//

import Foundation
import web3swift

// Note, Constants struct is a copy of that in web3swift lib.
// We need it here in scope to create the Web3 extension for Goerli

struct Constants {
    static let infuraHttpScheme = ".infura.io/v3/"
    static let infuraWsScheme = ".infura.io/ws/v3/"
    static let infuraToken = "4406c3acf862426c83991f1752c46dd8"
}

extension Web3 {
    public static func InfuraGoerliWeb3(accessToken: String? = nil) -> web3 {
        
        let urlString = "https://goerli\(Constants.infuraHttpScheme)\(Constants.infuraToken)"
        let url = URL(string: urlString)
        let web3 = try? Web3.new(url!)
        return web3!
    }
}
