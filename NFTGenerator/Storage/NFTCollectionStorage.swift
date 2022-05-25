//
//  NFTCollectionStorage.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 07/04/2022.
//

import Foundation
import CoreData
import Combine

class NFTCollectionStorage: NSObject, ObservableObject {
    
    var nftCollections = CurrentValueSubject<[NFTCollectionItem], Never>([])
    private let nftCollectionFetchController: NSFetchedResultsController<NFTCollectionItem>
    private(set) var persistenceController: PersistenceController
    
    public init(persistenceController: PersistenceController = PersistenceController.shared) {
        self.persistenceController = persistenceController
        nftCollectionFetchController = NSFetchedResultsController(
            fetchRequest: NFTCollectionItem.collectionOrderedRequest,
            managedObjectContext: persistenceController.container.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        super.init()
        nftCollectionFetchController.delegate = self
        fetchAll()
    }
    
    func addItem(name: String, symbol: String) throws -> NFTCollectionItem {
        let newItem = NFTCollectionItem(context: persistenceController.container.viewContext)
        newItem.name = name
        newItem.symbol = symbol
        try save()
        return newItem
    }
    
    func deleteCollection(collectionItem: NFTCollectionItem) {
        persistenceController.container.viewContext.delete(collectionItem)
    }
    
    func save() throws {
        do {
            try persistenceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            throw nsError
//            assertionFailure("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func fetchAll() {
        do {
            try nftCollectionFetchController.performFetch()
            nftCollections.value = nftCollectionFetchController.fetchedObjects ?? []
        } catch {
            debugPrint(error)
        }
    }
}

extension NFTCollectionStorage: NSFetchedResultsControllerDelegate {
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let nftCollections = controller.fetchedObjects as? [NFTCollectionItem] else { return }
        self.nftCollections.value = nftCollections
    }
}

extension NFTCollectionItem {

    static var collectionOrderedRequest: NSFetchRequest<NFTCollectionItem> {
        let request: NSFetchRequest<NFTCollectionItem> = NFTCollectionItem.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        return request
    }
    
    var sortByGeneratedIndex: NFTItem? {
        guard let children = self.children else { return nil }
        let childNFTItems = children.allObjects as! [NFTItem]
        return childNFTItems.sorted().first
    }
}

extension NFTItem: Comparable {
    public static func <(lhs: NFTItem, rhs: NFTItem) -> Bool {
        lhs.generatedIdx < rhs.generatedIdx
    }
}
