//
//  CollectionView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Foundation
import SwiftUI

struct CollectionView: View {
    
    var collection: NFTCollectionItem
    
    init(collection: NFTCollectionItem) {
        self.collection = collection
    }
    
    var body: some View {
        ZStack {
            if collection.contractAddress != nil {
                VStack {
                    HStack(spacing: 0) {
                        Spacer()
                        Images.contract
                            .font(.callout)
                            .modifier(ForegroundColorStyle(type: .mid))

                            .padding(.trailing, 4)
                            .padding(.vertical, 4)
                    }
                    Spacer()
                }
            }
            VStack {
                HStack(spacing: 0) {
                    Spacer()
                    Text(collection.name ?? "")
                        .modifier(ForegroundColorStyle(type: .standard))
                    Spacer()
                }
                Text(collection.symbol ?? "")
                    .modifier(ForegroundColorStyle(type: .standard))
                    .font(.caption2)
            }
        }
        .frame(height: 100)
        .cornerRadius(4)
    }
}

struct CollectionView_Previews: PreviewProvider {
    static var previews: some View {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController.preview)
        CollectionView(collection: nftCollectionStorage.nftCollections.value[0])
    }
}
