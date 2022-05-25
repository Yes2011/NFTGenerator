//
//  DatabaseService.swift
//  NFTGenerator
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import CoreData
import Foundation
import UIKit

class DatabaseService {
    
    func getAllNFTCollections() -> [NFTCollectionItem] {
        let request: NSFetchRequest<NFTCollectionItem> = NFTCollectionItem.fetchRequest()
        let moc = PersistenceController.shared.container.viewContext
        let results = try? moc.fetch(request)
        return results ?? [NFTCollectionItem]()
    }
}
