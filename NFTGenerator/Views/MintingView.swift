//
//  MintingView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 23/04/2022.
//

import SwiftUI

struct MintingView: View {

    @StateObject var viewModel: MintViewVM
    @State var ifpsImageUploading: Bool = false
    @State var ifpsTraitsUploading: Bool = false
    @State var isMinting: Bool = false
    @State var snapshot: UIImage?
    @State var mintingProgress: MintingProgress = .none
    let nftStandardSize = 350.0

    init(_ mintingVm: MintViewVM) {
        self._viewModel = StateObject(wrappedValue: mintingVm)
    }
    
    var body: some View {
        VStack {
            nftView
                .padding(12)
            Spacer()
        }
        .task {
            let snapshotter = Snapshotter()
            let view = nftView.ignoresSafeArea()
                .frame(width: nftStandardSize, height: nftStandardSize)
            let uiImage = snapshotter.rasterizeView(view, size: CGSize(width: nftStandardSize, height: nftStandardSize))
            mintingProgress = .ifpsImageUploading
            let pinImageResult = await viewModel.pinFileToIPFS(uiImage: uiImage)
            if pinImageResult {
                mintingProgress = .ifpsTraitsUploading
                let pinJSONResult = await viewModel.pinJSONToIPFS()
                if pinJSONResult {
                    mintingProgress = .minting
                    _ = await viewModel.mint(service: viewModel.contractService, address: viewModel.ethereumAddress, password: Wallet.getFromUserDefaults?.pwdFromKeychain ?? "")
                }
            }
        }
        .overlay(progressView)
    }
    
    var nftView: some View {
        VStack {
            NFTView(nftTrait: NFT.fromStorageItem(item: viewModel.nftItem))
                .aspectRatio(contentMode: .fit)
        }
    }
    
    var progressView: some View {
        return VStack {
            if mintingProgress != .none {
                ProgressView(mintingProgress.description)
                    .padding(16)
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
    }
}

struct MintingView_Previews: PreviewProvider {
    static var previews: some View {
        let nftCollectionStorage = NFTCollectionStorage(persistenceController: PersistenceController.preview)
        let nftItemStorage = NFTItemStorage(persistenceController: PersistenceController.preview, parent: nftCollectionStorage.nftCollections.value[0])
        let items = nftCollectionStorage.nftCollections.value[0].children!.allObjects
        let firstNFT: NFTItem = items[0] as! NFTItem
        let vm = MintViewVM(nftItem: firstNFT, nftItemStorage: nftItemStorage)
        MintingView(vm)
    }
}


extension View {

    func snapshot() -> UIImage {

        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view

        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear

        let renderer = UIGraphicsImageRenderer(size: targetSize)

        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}


enum MintingProgress: Int {
    case none, ifpsImageUploading, ifpsTraitsUploading, minting
}

extension MintingProgress: CustomStringConvertible {
    var description: String {
        switch self {
        case .none: return ""
        case .ifpsImageUploading: return Strings.uploadingImageToIpfs
        case .ifpsTraitsUploading: return Strings.uploadingTraitsToIpfs
        case .minting: return Strings.minting
        }
    }
}
