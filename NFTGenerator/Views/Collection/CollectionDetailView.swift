//
//  CollectionDetailView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Combine
import SwiftUI
import UIKit

struct CollectionDetailView: View {
    
    @StateObject var viewModel: CollectionDetailViewVM
    @State var name: String
    @State var symbol: String
    @State var isAlertPresented: Bool = false
    @State var isEditing: Bool = false
    @State var uiImage : UIImage? = nil
    let inputMinTextLength: Int = 3
    
    init(_ collectionVm: CollectionDetailViewVM) {
        self._viewModel = StateObject(wrappedValue: collectionVm)
        self.name = collectionVm.collection.name ?? ""
        self.symbol = collectionVm.collection.symbol ?? ""
    }
    
    var body: some View {
        VStack {
            if let image = uiImage {
                Image(uiImage: image)
            }
            if viewModel.collection.contractAddress != nil {
                hasContract
            } else {
                noContract
            }
        }
        .padding(16)
        .overlay(progressView)
        .alert(Strings.error, isPresented: $viewModel.showError, actions: {
            Button(Strings.ok, role: nil, action: {})
        }, message: {
            Text(viewModel.errorMessage)
        })
        .navigationBarTitle(Strings.collection, displayMode: .inline)
//        .navigationBarItems(
//            trailing:
//                Button("Delete") {
//                    viewModel.removeItems()
//                }
//        )
    }
    
    var hasContract: some View {
        VStack {
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text(name)
                        .font(.title)
                }
                HStack(alignment: .lastTextBaseline) {
                    Text(Strings.symbolColon)
                        .font(.caption)
                    Text(symbol)
                }
                Link(destination: URL(string: MiscStrings.etherscan + (viewModel.collection.contractAddress!))!) {
                    VStack {
                        Text(Strings.etherscan)
                            .font(.caption)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            if viewModel.collectionCount != 10000  {
                generateButtons
                    .padding(.top, 32)
                Spacer()
            } else {
                GeometryReader { geo in
                    let vGridLayout = [GridItem(.fixed(geo.size.width / 2)), GridItem(.fixed(geo.size.width / 2))]
                    ScrollView {
                        LazyVGrid(columns: vGridLayout) {
                            ForEach(viewModel.items, id: \.self) { item in
                                nftInfoView(item: item, geo: geo)
                                    .background(Color.black.opacity(0.025))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var noContract: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text(Strings.nameColon)
                    .font(.caption)
                TextField(name, text: $name, onEditingChanged: { isEditing in
                    self.isEditing = isEditing
                })
                .modifier(TextFieldStyle(
                    viewModel: viewModel,
                    name: name,
                    symbol: symbol,
                    type: .name,
                    minLength: inputMinTextLength))
            }
            .padding(.bottom, 8)
            HStack(alignment: .firstTextBaseline) {
                Text(Strings.symbolColon)
                    .font(.caption)
                TextField(symbol, text: $symbol) { isEditing in
                    self.isEditing = isEditing
                }
                .modifier(TextFieldStyle(
                    viewModel: viewModel,
                    name: name,
                    symbol: symbol,
                    type: .symbol,
                    minLength: inputMinTextLength))
            }
            if name.count >= inputMinTextLength && symbol.count >= inputMinTextLength && isEditing == false {
                if viewModel.collection.contractDeployHash == nil {
                    deployButton
                        .padding(.top, 16)
                }
            }
            Spacer()
        }
        .padding(8)
    }
    
    func nftInfoView(item: NFTItem, geo: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            NFTView(nftTrait: NFT.fromStorageItem(item: item))
                .background(Color.white)
                .cornerRadius(8)
                .padding(8)
            Spacer()
            VStack(spacing: 0) {
                if item.mintTransaction != nil {
                    openseaLink(item: item)
                } else {
                    mintButton(item: item)
                }
            }
            .frame(height: 36)
            .padding(.bottom, 8)
        }
        .frame(height: (geo.size.width / 2) + 52 )
    }

    
    var progressView: some View {
        var message = Strings.deploying
        if viewModel.isGenerating {
            message = Strings.generating
        }
        return VStack {
            if viewModel.isGenerating || viewModel.isDeploying {
                ProgressView(message)
                    .padding(16)
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
    }
    
    func openseaLink(item: NFTItem) -> some View {
        let urlString = MiscStrings.opensea + (viewModel.collection.contractAddress!) + "/\(item.generatedIdx)"
        return Link(destination: URL(string: urlString)!) {
            VStack {
                Text(Strings.opensea)
            }
        }
    }

}

extension CollectionDetailView {
    
    var deployButton: some View {
        Button(action: {
            isAlertPresented.toggle()
        }) {
            Text(Strings.deployContract)
        }
        .tint(.green)
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.roundedRectangle(radius: 8))
        .controlSize(.large)
        .alert(Strings.deployConfirmation, isPresented: $isAlertPresented, actions: {
            Button(Strings.ok, role: nil, action: {
                Task {
                    try? await viewModel.deploy(service: viewModel.contractService,
                                                ethereumAddress: viewModel.ethereumAddress, walletPassword: viewModel.wallet?.pwdFromKeychain ?? "")
                }
            })
            Button(Strings.cancel, role: .cancel, action: {})
        }, message: {
            Text(Strings.deployConfirmation(name: name, symbol: symbol))
        })
    }
        
    func mintButton(item: NFTItem) -> some View {
        VStack {
            NavigationLink(destination: MintingView(MintViewVM(nftItem: item, nftItemStorage: viewModel.nftItemStorage))) {
                Text(Strings.mintMe)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 2)
            }
            .tint(.green)
            .buttonStyle(.borderedProminent)
            .cornerRadius(8)
            .padding(.bottom, 4)
        }
    }
    
    var generateButtons: some View {
        VStack {
            Button(action: {
                Task {
                    await viewModel.generateCollectionItems()
                }
            }) {
                Text(Strings.generateImages)
            }
            .tint(.green)
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 8))
            .controlSize(.large)
        }
    }
}

private struct TextFieldStyle: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    var viewModel: CollectionDetailViewVM
    var name: String
    var symbol: String
    var type: TextFieldStyleType
    var minLength: Int
    
    enum TextFieldStyleType {
        case name, symbol
    }

    func body(content: Content) -> some View {
        return content
            .foregroundColor(isLengthTooShort ? Color.red :  colorScheme == .dark ? .white : .black.opacity(0.9))
            .font(.body)
            .textFieldStyle(.roundedBorder)
            .submitLabel(.done)
            .disableAutocorrection(true)
            .padding(4)
            .onSubmit {
                viewModel.updateName(newValue: name)
                viewModel.updateSymbol(newValue: symbol)
            }
    }
        
    var isLengthTooShort: Bool {
        switch type {
            case .name:
                return name.count < minLength
            case .symbol:
                return symbol.count < minLength
        }
    }
}

struct CollectionDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController.preview)
        let collection1 = nftCollectionStorage.nftCollections.value[0]
        collection1.contractAddress = nil
        let collection2 = nftCollectionStorage.nftCollections.value[1]
        collection2.contractAddress = "0x"
        return Group {
            CollectionDetailView(CollectionDetailViewVM(nftCollectionStorage: nftCollectionStorage,
                                                        collection: collection1))
            CollectionDetailView(CollectionDetailViewVM(nftCollectionStorage: nftCollectionStorage,
                                                        collection: collection1))
            CollectionDetailView(CollectionDetailViewVM(nftCollectionStorage: nftCollectionStorage,
                                                        collection: collection2))
            .preferredColorScheme(.dark)
        }

    }
}
