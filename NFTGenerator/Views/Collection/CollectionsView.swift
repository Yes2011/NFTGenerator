//
//  CollectionsView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import SwiftUI
import CoreData

struct CollectionsView: View {
    
    @StateObject var viewModel: CollectionsViewVM
    @Environment(\.currentWallet) var currentWallet
    @Environment(\.colorScheme) var colorScheme
    @State var activateNavigationLink = false
    
    init(collectionsVm: CollectionsViewVM) {
        self._viewModel = StateObject(wrappedValue: collectionsVm)
    }

    var body: some View {
        NavigationView {
            bodyView
                .navigationTitle(currentWallet.wrappedValue == nil ? Strings.createWallet : Strings.collections)
                .navigationBarItems(
                    trailing:
                        NavigationLink(destination: destinationView, isActive: $activateNavigationLink) {
                            navBarButton
                    }
                )
        }
        .navigationViewStyle(.stack)
    }
    
    @ViewBuilder
    var bodyView: some View {
        if currentWallet.wrappedValue == nil {
            noWalletView
        } else {
            hasWalletView
        }
    }
    
    @ViewBuilder
    var navBarButton: some View {
        if self.currentWallet.wrappedValue != nil {
            Button(Strings.add) {
                viewModel.addNFTCollection(name: Strings.newCollection, symbol: Strings.defaultCollectionSymbol)
                activateNavigationLink = true
            }
        } else {
            EmptyView()
        }
    }
    
    // inspired by SO: https://stackoverflow.com/a/64089413
    // Author: https://stackoverflow.com/users/8697793/pawello2222
    @ViewBuilder
    var destinationView: some View {
        if let collection = viewModel.addedCollection {
            CollectionDetailView(CollectionDetailViewVM(collection: collection))
        } else {
            EmptyView()
        }
    }
        
    var noWalletView: some View {
        VStack {
            VStack {
                Text(Strings.setUpWallet)
                Text(Strings.doNotUseRealMoney)
                    .padding(.bottom, 16)
                NavigationLink(destination: CreateWalletView()) {
                    Text(Strings.createWallet)
                }
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.bottom, 4)

            }
            .padding(32)
            .background(Color.black.opacity(0.01))
            .cornerRadius(8)
            Spacer()
        }
    }
    
    var hasWalletView: some View {
        VStack(spacing: 0) {
            List {
                ForEach(viewModel.collections, id: \.self) { collection in
                    let detailVm = CollectionDetailViewVM(collection: collection)
                    
                    ZStack {
                        NavigationLink(destination:
                                        CollectionDetailView(detailVm)
                        ) { EmptyView() }
                        .opacity(0.0)
                        .buttonStyle(PlainButtonStyle())
                        HStack {
                            collectionView(collection: collection)
                        }
                    }
                }
                .onDelete { idxSet in
                    viewModel.deleteCollection(idxSet: idxSet)
                }
            }
            .listStyle(.plain)
            WalletView(walletVm: WalletViewVM())
        }
    }

    
}

extension CollectionsView {

    func collectionView(collection: NFTCollectionItem) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(lineWidth: 1)
                .fill(Color.black.opacity(0.1))
            HStack {
                VStack(alignment: .leading) {
                    Text(collection.name ?? "")
                        .modifier(ForegroundColorStyle(type: .standard))
                    Text(Strings.symbolColonWithSymbol(symbol: collection.symbol))
                        .modifier(ForegroundColorStyle(type: .standard))
                        .font(.caption2)
                    Text(Strings.itemsWithCount(count: collection.children?.count))
                        .modifier(ForegroundColorStyle(type: .standard))

                         .font(.caption2)
                    Text(Strings.mintedWithCount(count: viewModel.collectionMintedCount(collection: collection)))
                        .modifier(ForegroundColorStyle(type: .standard))
                         .font(.caption2)
                    
                }
                Spacer()
                if let firstChild = collection.sortByGeneratedIndex {
                    NFTView(nftTrait: NFT.fromStorageItem(item: firstChild))
                        .background(Color.white)
                        .cornerRadius(8)
                        .frame(width: 60, height: 60)

                }
            }
            .padding(.leading, 16)
            .padding(.trailing, 8)
            .padding(.vertical, 8)

            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.025))
        }
    }
}


struct CollectionsView_Previews: PreviewProvider {
    static var previews: some View {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController.preview)
        let collectionsVm = CollectionsViewVM(nftCollectionStorage: nftCollectionStorage)
        CollectionsView(collectionsVm: collectionsVm)
    }
}

extension CollectionsView {
    
    var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button {
                    viewModel.addNFTCollection(name: Strings.newCollection, symbol: Strings.defaultCollectionSymbol)
                } label: {
                    Image(systemName: Strings.plus)
                        .font(.title)
                        .modifier(ForegroundColorStyle(type: .standard))
                        .modifier(ImageFrameStyle(size: .large))
                        .background(Circle().fill(.regularMaterial))
                }
                .padding(.bottom, 16)
                .padding(.trailing, 12)
            }
        }
    }
}
