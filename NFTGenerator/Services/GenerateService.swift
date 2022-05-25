//
//  GenerateService.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 17/05/2022.
//

import Foundation

struct GenerateService {
        
    let nftGenerator = NFTGenerator()
    private(set) var nftItemStorage: NFTItemStorage
    
    func generateNFTImages(maxItems: Int = 10000, backgroundParent: NFTCollectionItem?) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            generateNFTImages(maxItems: maxItems, backgroundParent: backgroundParent) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func generateNFTImages(maxItems: Int = 10000, backgroundParent: NFTCollectionItem?, completion: @escaping (Error?) -> Void) {
        var nfts = Set<NFT>(minimumCapacity: maxItems)
        var idx: Int = 0
        DispatchQueue.global(qos: .userInitiated).async {
            var existingNft: NFT? = nil
            repeat {
                let randomNft = nftGenerator.randomNFT(generatedIdx: idx)
                existingNft = nfts.update(with: randomNft)
                if existingNft == nil {
                    idx = idx + 1
                }
            } while existingNft == nil && idx < maxItems
            for nft in nfts {
                do {
                    try self.nftItemStorage.addItem(nft: nft, backgroundParent: backgroundParent)
                } catch {
                    completion(error)
                    return
                }
            }
            do {
                try self.nftItemStorage.save(background: true)
            } catch {
                completion(error)
            }
            completion(nil)
        }
    }
}
