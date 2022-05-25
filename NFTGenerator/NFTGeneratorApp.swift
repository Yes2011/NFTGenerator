//
//  NFTGeneratorApp.swift
//  Shared
//
//  Created by YES 2011 Limited on 17/03/2022.
//

import SwiftUI
import SFSymbols

@main
struct NFTGeneratorApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(items: SFCategory.all.symbols)
        }
    }
}

extension EnvironmentValues {
    var currentWallet: Binding<Wallet?> {
        get { self[CurrentWalletKey.self] }
        set { self[CurrentWalletKey.self] = newValue }
    }
}

struct CurrentWalletKey: EnvironmentKey {
    static var defaultValue: Binding<Wallet?> = .constant(Wallet.getFromUserDefaults)
}
