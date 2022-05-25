//
//  ContentView.swift
//  Shared
//
//  Created by YES 2011 Limited on 17/03/2022.
//

import SwiftUI
import CoreData
import SFSymbols

struct ContentView: View {

    @State var wallet: Wallet? = Wallet.getFromUserDefaults
    var items: [SFSymbol]

    var body: some View {
        CollectionsView(collectionsVm: CollectionsViewVM())
            .environment(\.currentWallet, $wallet)
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(items: SFSymbol.allSymbols)
    }
}
