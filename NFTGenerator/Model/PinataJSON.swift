//
//  PinataJSON.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 26/04/2022.
//

import Foundation

struct PinataJSON: Codable {
    
    let pinataMetadata: PinataMetadata
    let pinataContent: NFTTrait
}

struct PinataMetadata: Codable {
    let name: String
}
