//
//  NFTItemStorage.swift
//  NFTGenerator (iOS)
//
//  Created by Crispin Lingford on 21/04/2022.
//

import Foundation
import CoreData
import Combine

enum StorageError: Error {

  case noParent
}


class NFTItemStorage: NSObject, ObservableObject {
    
    var nftItems = CurrentValueSubject<[NFTItem], Never>([])
    private let nftItemFetchController: NSFetchedResultsController<NFTItem>
    private(set) var persistenceController: PersistenceController
    private let parent: NFTCollectionItem
    
    lazy private var backgroundParent: NFTCollectionItem? = {
        fetchParentForBackground(mainContextCollection: parent)
    }()

    public init(persistenceController: PersistenceController = PersistenceController.shared, parent: NFTCollectionItem) {
        
        self.persistenceController = persistenceController
        self.parent = parent
        nftItemFetchController = NSFetchedResultsController(
            fetchRequest: NFTItem.itemsOrderedRequest(parent: parent),
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()

        nftItemFetchController.delegate = self
        fetchAll()
    }
    
    func addItem(nft: NFT, backgroundParent: NFTCollectionItem? = nil) throws {
        let newItem = NFTItem(context: backgroundParent != nil ? persistenceController.backgroundContext : persistenceController.container.viewContext)
        newItem.id = nft.id
        newItem.generatedIdx = Int32(nft.generatedIdx)
        newItem.primarySymbol = nft.primarySymbol
        newItem.primaryRotationTypeValue = nft.primaryRotationType.int16
        newItem.primaryBackgroundColorValue = nft.primaryBackgroundColor.int16
        newItem.primaryBorderTypeValue = nft.primaryBorderType.int16
        newItem.secondarySymbol = nft.secondarySymbol
        newItem.secondaryRotationValue = nft.secondaryRotation.int16
        newItem.secondaryBackgroundColorValue = nft.secondaryBackgroundColor.int16
        newItem.secondaryBorderTypeValue = nft.secondaryBorderType.int16
        newItem.secondaryTileSlotValue = nft.secondaryTileSlot.int16
        if backgroundParent != nil {
            newItem.parent = backgroundParent!
        } else {
            if parent.managedObjectContext == nil {
                throw StorageError.noParent
            }
            newItem.parent = parent
        }
    }
    
    func deleteItem(nftItem: NFTItem, background: Bool = false) {
        if background == true {
            persistenceController.backgroundContext.delete(nftItem)
        } else {
            persistenceController.container.viewContext.delete(nftItem)
        }
    }
    
    func save(background: Bool = false) throws {
        do {
            if background == true {
                try persistenceController.backgroundContext.save()
            } else {
                try persistenceController.container.viewContext.save()
            }
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
//            throw nsError
            assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func deleteAll(background: Bool = false) throws {
        
        var context = persistenceController.container.viewContext
        var fetchRequest = NFTItem.itemsOrderedRequest(parent: parent)
        if background == true {
            context = persistenceController.backgroundContext
            if let backgroundParent = backgroundParent {
                fetchRequest = NFTItem.itemsOrderedRequest(parent: backgroundParent)
            }
        }
        do {
            let objects = try context.fetch(fetchRequest)
            objects.forEach { item in
                deleteItem(nftItem: item, background: background)
            }
        } catch {
            debugPrint(error)
        }
        try save(background: background)
        fetchAll()
    }
    
    private func fetchAll() {
        do {
            try nftItemFetchController.performFetch()
            nftItems.value = nftItemFetchController.fetchedObjects ?? []
        } catch {
            debugPrint(error)
        }
    }
    
    func fetchParentForBackground(mainContextCollection: NFTCollectionItem?) -> NFTCollectionItem? {
        
        guard let collection = mainContextCollection else { return nil }
        guard let contractAddress = collection.contractAddress else { return nil }

        let fetchRequest: NSFetchRequest<NFTCollectionItem>
        fetchRequest = NFTCollectionItem.fetchRequest()

        fetchRequest.predicate = NSPredicate(
            format: "contractAddress == %@", contractAddress
        )
        
        let context = persistenceController.backgroundContext

        // Perform the fetch request to get the objects
        // matching the predicate
        do {
            let objects = try context.fetch(fetchRequest)
            if objects.count > 0 {
                return objects.first
            }
        } catch {
            debugPrint(error)
        }
        return nil
    }
    
    func refreshAllObjects(background: Bool = false) {
        if background == true {
            persistenceController.container.viewContext.refreshAllObjects()
        } else {
            persistenceController.backgroundContext.refreshAllObjects()
        }
    }
}

extension NFTItemStorage: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let nftItems = controller.fetchedObjects as? [NFTItem] else { return }
        self.nftItems.value = nftItems
    }
}

extension NFTItem {

    static func itemsOrderedRequest(parent: NFTCollectionItem) -> NSFetchRequest<NFTItem> {
        let request: NSFetchRequest<NFTItem> = NFTItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "generatedIdx", ascending: true)]
        let parentPredicate = NSPredicate(format: "parent == %@", parent)
        request.predicate = parentPredicate
        return request
    }
    
    var fileName: String {
        "\(generatedIdx)-\(parent?.name ?? "")"
    }
    
    var imagePath: String {
        guard let ifpsHash = ipfsImageHash else { return "" }
        return "ipfs://\(ifpsHash)?filename=\(fileName).png"
    }
    var jsonPath: String {
        guard let ifpsHash = ipfsJSONHash else { return "" }
        return "ipfs://\(ifpsHash)?filename=\(fileName).json"
    }
}
