//
//  WalletUIView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 16/04/2022.
//

import SwiftUI

struct WalletView: View {
    
    @StateObject var viewModel: WalletViewVM
    @State var generatedPwd: String = ""
    @State var balance: String = "0.0"

    init(walletVm: WalletViewVM) {
        self._viewModel = StateObject(wrappedValue: walletVm)
    }
    
    var body: some View {
        if viewModel.wallet == nil {
            noWallet
        } else {
            wallet
        }
    }
}

extension WalletView {
    
    var wallet: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 24)
                .strokeBorder(Color.black.opacity(0.2), lineWidth: 0.5)
                .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.black.opacity(0.025))
                        )
                .frame(height: 80)
                .offset(x: 0, y: 16)
            VStack {
                HStack {
                    Text(Strings.walletBalance(balance: balance))
                        .font(.body)
                    Button {
                        Task {
                            balance = await viewModel.getBalance()
                        }
                    } label: {
                        Images.refresh
                            .modifier(ForegroundColorStyle(type: .light))
                            .font(.caption)
                    }
                }
                HStack {
                    Text(Strings.goerliColon)
                        .font(.caption)
                    Button {
                        UIPasteboard.general.string = viewModel.wallet!.address
                    } label: {
                        Images.copy
                            .modifier(ForegroundColorStyle(type: .light))
                            .font(.caption)
                    }
                    Link(destination: URL(string: MiscStrings.etherscan + (viewModel.wallet!.address))!) {
                        Images.contract
                            .modifier(ForegroundColorStyle(type: .light))
                            .font(.caption)
                    }
                }
            }
            .padding(.top, 16)
            .task {
                balance = await viewModel.getBalance()
            }
        }
    }
    
    var noWallet: some View {
        VStack {
            VStack {
                Text(Strings.setUpWallet)
                Text(Strings.doNotUseRealMoney)
                    .padding(.bottom, 16)
                NavigationLink(destination: CreateWalletView()) {
                    Text(Strings.createWallet)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(4)
                .padding(.bottom, 4)

            }
            .padding(32)
            .background(Color.black.opacity(0.1))
            .cornerRadius(8)
            Spacer()
        }
    }
    
}

struct WalletUIView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WalletView(walletVm: WalletViewVM())
            WalletView(walletVm: WalletViewVM(wallet: Wallet.previewWallet))
            
        }
    }
}
