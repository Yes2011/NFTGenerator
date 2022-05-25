//
//  CollectionViewViewModel.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Combine
import Foundation
import SwiftUI
import web3swift

@MainActor
class CollectionDetailViewVM: ObservableObject {

    @Published private(set) var collection: NFTCollectionItem
    @Published private(set) var items: [NFTItem] = []
    @Published var showError: Bool = false
    @Published var nftGenerateCount: Int = 0
    @Published var isGenerating: Bool = false
    @Published var isDeploying: Bool = false
    private var cancellable: AnyCancellable?
    private(set) var nftCollectionStorage: NFTCollectionStorage
    private(set) var nftItemStorage: NFTItemStorage
    private(set) var errorMessage: String = ""
    
    private(set) var wallet: Wallet?
    private(set) var contractService: ContractService = ContractService()
    private(set) var ethereumAddress: EthereumAddress?

    init(nftCollectionStorage: NFTCollectionStorage = NFTCollectionStorage(),
         collection: NFTCollectionItem,
         wallet: Wallet? = Wallet.getFromUserDefaults) {
        self.nftCollectionStorage = nftCollectionStorage
        self.nftItemStorage = NFTItemStorage(persistenceController: nftCollectionStorage.persistenceController, parent: collection)
        self.collection = collection
        self.wallet = wallet
        if let wallet = wallet {
            let keystore = KeystoreHelper.getKeystoreManager(wallet: wallet)
            contractService = ContractService(keystore: keystore)
            ethereumAddress = EthereumAddress(wallet.address)
        }
        var nftCollectionItemsPublisher: AnyPublisher<[NFTItem], Never>
        nftCollectionItemsPublisher = self.nftItemStorage.nftItems.eraseToAnyPublisher()
        cancellable = nftCollectionItemsPublisher.sink { items in
            self.items = items
        }

//        debugPrint(collection.name)
//        debugPrint(collection.symbol)
//        debugPrint(collection.contractAddress)
    }
    
    func addNFTCollection(name: String, symbol: String) throws -> NFTCollectionItem {
        try nftCollectionStorage.addItem(name: name, symbol: symbol)
    }
    
    func updateName(newValue: String) {
        collection.name = newValue
        updateCollectionStorage()
    }
    
    func updateSymbol(newValue: String) {
        collection.symbol = newValue
        updateCollectionStorage()
    }
    
    func deploy(service: ContractService?, ethereumAddress: EthereumAddress?, walletPassword: String) async throws -> Bool {
        guard collection.contractAddress == nil else { return false }
        let parameters = [
            collection.name,
            collection.symbol
        ] as [AnyObject]
            isDeploying = true
        if let contractService = service, let address = ethereumAddress, let result = try await contractService.deploy(from: address, parameters: parameters, password: walletPassword) {
            collection.contractDeployHash = result.hash
            updateCollectionStorage()
            let receipt = await contractService.fetchTransactionReceipt(txHash: result.hash)
            if let receipt = receipt,
                let contractAddress = receipt.contractAddress {
                collection.contractAddress = contractAddress.address
                updateCollectionStorage()
                isDeploying = false
                debugPrint(" result = \(String(describing: result))")
                return true
            } else {
                isDeploying = false
            }
        } else {
            isDeploying = false
        }
        return false
    }

    func generateCollectionItems(maxItems: Int = 10000) async {
        
        self.isGenerating = true
        let generateService = GenerateService(nftItemStorage: nftItemStorage)
        let backgroundParent = self.nftItemStorage.fetchParentForBackground(mainContextCollection: collection)
        do {
            try await generateService.generateNFTImages(maxItems: maxItems, backgroundParent: backgroundParent)
            self.isGenerating = false
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
            self.isGenerating = false
        }
    }
    
    func removeItems() {
        try? self.nftItemStorage.deleteAll(background: true)
        try? self.nftItemStorage.deleteAll(background: false)
    }
    
    var collectionCount: Int {
        collection.children?.count ?? 0
    }
}

extension CollectionDetailViewVM {

    private func updateCollectionStorage() {
        do {
            try collection.validateForUpdate()
            try nftCollectionStorage.save()
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
