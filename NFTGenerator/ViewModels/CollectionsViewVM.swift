//
//  CollectionsViewModel.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import Combine
import Foundation
import SwiftUI

class CollectionsViewVM: ObservableObject {

    @Published private(set) var collections: [NFTCollectionItem] = []
    @Published var addedCollection: NFTCollectionItem?
    @Published var showError: Bool = false
    @Published var wallet: Wallet?
    private var cancellables = Set<AnyCancellable>()
    private(set) var nftCollectionStorage: NFTCollectionStorage
    private var pinataService = PinataService()
    private(set) var errorMessage: String = ""

    init(nftCollectionStorage: NFTCollectionStorage = NFTCollectionStorage(), wallet: Wallet? = Wallet.getFromUserDefaults) {
        self.nftCollectionStorage = nftCollectionStorage
        self.wallet = wallet
        var nftCollectionPublisher: AnyPublisher<[NFTCollectionItem], Never>
        nftCollectionPublisher = self.nftCollectionStorage.nftCollections.eraseToAnyPublisher()
        nftCollectionPublisher.sink { collections in
            self.collections = collections
        }.store(in: &cancellables)


    }
    
    func addNFTCollection(name: String, symbol: String) {
        do {
            addedCollection = try nftCollectionStorage.addItem(name: name, symbol: symbol)
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }
    
    func deleteCollection(idxSet: IndexSet) {
        let collection = collections[idxSet.first!]
        nftCollectionStorage.deleteCollection(collectionItem: collection)
        try? nftCollectionStorage.save()
        collections.remove(atOffsets: idxSet)
    }
    
    func collectionMintedCount(collection: NFTCollectionItem) -> Int {
        
        let predicate = NSPredicate(format: "isMinted == YES")
        return collection.children?.filtered(using: predicate).count ?? 0
    }
}
