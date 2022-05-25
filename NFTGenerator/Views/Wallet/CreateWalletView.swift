//
//  CreateWalletView.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 16/04/2022.
//

import SwiftUI

struct CreateWalletView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.currentWallet) var currentWallet
    @Environment(\.colorScheme) var colorScheme
    @StateObject var viewModel: CreateWalletViewVM
    @State var password: String = ""
    @State var isAlertPresented: Bool = false
    @State var isEditing: Bool = false
    @State var isPasswordValidated = false

    init(_ createWalletVm: CreateWalletViewVM = CreateWalletViewVM()) {
        self._viewModel = StateObject(wrappedValue: createWalletVm)
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Text(Strings.passwordColon)
                    .font(.caption)
                TextField(Strings.enterStrongPassword, text: $password) { isEditing in
                    self.isEditing = isEditing
                }
                .font(.body)
                .foregroundColor(password.count < 3 ? Color.red : colorScheme == .dark ? .white : .black.opacity(0.9))
                .textFieldStyle(.roundedBorder)
                .submitLabel(.done)
                .disableAutocorrection(true)
                .padding(4)
                .onSubmit {
                    isPasswordValidated = viewModel.validatePassword(password: password)
                }
            }
            createGenerateButton
                .tint(.green)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.top, 16)
            Spacer()
        }
        .padding(.horizontal, 16)
        .overlay(progressView)
        .alert(Strings.error, isPresented: $viewModel.showError, actions: {
            Button(Strings.ok, role: nil, action: {})
        }, message: {
            Text(viewModel.errorMessage)
        })
        .alert(Strings.success, isPresented: $viewModel.isWalletCreated, actions: {
            Button(Strings.ok, role: nil, action: {
                self.currentWallet.wrappedValue = Wallet.getFromUserDefaults
                self.presentationMode.wrappedValue.dismiss()
            })
        }, message: {
            Text(Strings.walletCreated)
        })
    }
    
    @ViewBuilder
    var createGenerateButton: some View {
        if isPasswordValidated && !isEditing {
            Button(Strings.createWallet) {
                Task {
                    await viewModel.createWallet(password: password)
                }
            }
        } else {
            Button(Strings.generatePassword) {
                password = viewModel.generatePassword()
                isPasswordValidated = viewModel.validatePassword(password: password)
            }
        }
    }
    
    var progressView: some View {
        let message = Strings.creatingWallet
        return VStack {
            if viewModel.isWalletCreateInProgress == true {
                ProgressView(message)
                    .padding(16)
                    .background(Material.ultraThinMaterial)
                    .cornerRadius(8)
            }
        }
    }
}

extension CreateWalletView {
    
    func button(title: String) -> some View {
        Button(action: {
        }, label: {
            Text(title)
        })
        .padding(8)
        .foregroundColor(.white)
        .background(Color.green)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.bottom, 4)
    }
}

struct CreateWalletView_Previews: PreviewProvider {
    static var previews: some View {
        CreateWalletView()
    }
}
