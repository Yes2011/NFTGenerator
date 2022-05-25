//
//  MintViewVM.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 23/04/2022.
//

import Combine
import Foundation
import SwiftUI
import web3swift

class MintViewVM: ObservableObject {
    
    @Published var ifpsPublisher: Bool = false
    @Published var showError: Bool = false
    private(set) var nftItemStorage: NFTItemStorage
    var nftItem: NFTItem
    private(set) var errorMessage: String = ""
    private(set) var wallet: Wallet?
    private(set) var contractService: ContractService = ContractService()
    private(set) var ethereumAddress: EthereumAddress?

    init(nftItem: NFTItem, nftItemStorage: NFTItemStorage, wallet: Wallet? = Wallet.getFromUserDefaults) {
        self.nftItem = nftItem
        self.nftItemStorage = nftItemStorage
        self.wallet = wallet
        if let wallet = wallet {
            let keystore = KeystoreHelper.getKeystoreManager(wallet: wallet)
            contractService = ContractService(keystore: keystore)
            ethereumAddress = EthereumAddress(wallet.address)
        }
    }
        
    func pinFileToIPFS(uiImage: UIImage?, service: PinataService = PinataService()) async -> Bool {
        guard let image = uiImage,
                let imageData = image.jpegData(compressionQuality: 1) else { return false }
        guard let result = try? await service.pinFile(data: imageData, fileName: "\(nftItem.fileName).jpg") else { return false }
        nftItem.ipfsImageHash = result.hash
        updateCollectionStorage()
        debugPrint(" returned = \(result)")
        return true
    }
    
    func pinJSONToIPFS(service: PinataService = PinataService()) async -> Bool {
        guard let ifpsHash = nftItem.ipfsImageHash else { return false }
        let nft = NFT.fromStorageItem(item: nftItem)
        let nftTraits = NFTTrait(nft: nft, ifpsHash: ifpsHash, fileName: nftItem.fileName)
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        guard let data = try? encoder.encode(nftTraits) else { return false }
        guard let result = try? await service.pinFile(data: data, fileName: "\(nftItem.fileName).json") else { return false }
        nftItem.ipfsJSONHash = result.hash
        updateCollectionStorage()
        debugPrint(" returned = \(result)")
        return true
    }
    
    func mint(service: ContractService?, address: EthereumAddress?, password: String) async -> Bool {
        guard nftItem.ipfsJSONHash != nil else { return false }
        guard let parent = nftItem.parent, let contractAddress = parent.contractAddress else { return false }
        guard let contractEthereumAddress = EthereumAddress(contractAddress) else { return false }
        guard let contractService = service, let walletEthereumAddress = address,
            let result = try? await contractService.mint(from: walletEthereumAddress,
                                                             at: contractEthereumAddress,
                                                             tokenId: Int(nftItem.generatedIdx),
                                                             tokenURI: nftItem.jsonPath, password: password) else {
            return false
        }
        debugPrint(" returned from minting = \(result)")
        nftItem.mintTransaction = result.hash
        nftItem.isMinted = true
        updateCollectionStorage()
        nftItemStorage.refreshAllObjects()
        nftItemStorage.persistenceController.container.viewContext.refreshAllObjects()
        return false
    }
}

extension MintViewVM {

    private func updateCollectionStorage() {
        do {
            try nftItemStorage.save()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
