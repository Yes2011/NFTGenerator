//
//  Persistence.swift
//  Shared
//
//  Created by YES 2011 Limited on 17/03/2022.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    static var unitTest: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        return result
    }()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for idx in 0..<2 {
            let newCollection = NFTCollectionItem(context: viewContext)
            newCollection.name = "Derek and the Dominoes"
            newCollection.symbol = "DDS"
            newCollection.contractAddress = idx % 2 == 0 ? "0x" : nil
            if newCollection.contractAddress != nil {
                let newNFTs = [NFTGenerator().randomNFT(), NFTGenerator().randomNFT(), NFTGenerator().randomNFT(), NFTGenerator().randomNFT()]
                var idx2 = 1
                newNFTs.forEach { nft in
                    let newItem = NFTItem(context: viewContext)
                    newItem.id = nft.id
                    newItem.generatedIdx = Int32(idx2)
                    idx2 = idx2 + 1
                    newItem.mintTransaction = idx2 % 2 == 0 ? "0x" : nil
                    newItem.primarySymbol = nft.primarySymbol
                    newItem.primaryRotationTypeValue = nft.primaryRotationType.int16
                    newItem.primaryBackgroundColorValue = nft.primaryBackgroundColor.int16
                    newItem.primaryBorderTypeValue = nft.primaryBorderType.int16
                    newItem.secondarySymbol = nft.secondarySymbol
                    newItem.secondaryRotationValue = nft.secondaryRotation.int16
                    newItem.secondaryBackgroundColorValue = nft.secondaryBackgroundColor.int16
                    newItem.secondaryBorderTypeValue = nft.secondaryBorderType.int16
                    newItem.secondaryTileSlotValue = nft.secondaryTileSlot.int16
                    newItem.parent = newCollection
                }
            }
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "NFTGenerator")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    private(set) lazy var backgroundContext: NSManagedObjectContext = {
        let backgroundContext = container.newBackgroundContext()
        backgroundContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return backgroundContext
    }()
}
