//
//  NFTView.swift
//  NFTGenerator
//
//  Created by YES 2011 Limited on 06/04/2022.
//

import SwiftUI
import SFSymbols

struct NFTView: View {
    
    var nftTrait: NFT
    let columnCount = 4
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                ZStack {
                    secondaryTiles(nftTrait: nftTrait, frameSize: geo.size.width/CGFloat(columnCount))
                    primaryTile(nftTrait: nftTrait, frameSize: geo.size.width)
                    uuidLabel(nftTrait: nftTrait, frameSize: geo.size.width)
                }
            }
        }
        .overlay(
            RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
                .stroke(Color.black.opacity(0.9), lineWidth: 1)
        )
        .clipShape(
              RoundedRectangle(cornerSize: CGSize(width: 8, height: 8))
            )
    }
}

extension NFTView {
    
    func generateSecondaryTile(tileType: TileType, nftTrait: NFT, frameSize: CGFloat) -> some View {
        VStack {
            if tileType == nftTrait.secondaryTileSlot {
                SecondaryTile(nftTrait: nftTrait, frameSize: frameSize)
                    .overlay {
                        borderOverlay(borderType: nftTrait.secondaryBorderType)
                    }
            }
        }
    }
    
    func primaryTile(nftTrait: NFT, frameSize: CGFloat) -> some View {
        let primaryTileSize = frameSize/3
        return Image(systemName: nftTrait.primarySymbol)
            .colorScheme(.light)
            .frame(width: primaryTileSize, height: primaryTileSize)
            .font(.system(size: primaryTileSize/2, weight: .light, design: .default))
            .rotationEffect(Angle(degrees: Double(nftTrait.primaryRotationType.rawValue)))
            .background(nftTrait.primaryBackgroundColor.color)
            .cornerRadius(4)
            .overlay {
                borderOverlay(borderType: nftTrait.primaryBorderType)
            }
    }
    
    func secondaryTiles(nftTrait: NFT, frameSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(row, id: \.self) { tileType in
                        generateSecondaryTile(tileType: tileType, nftTrait: nftTrait, frameSize: frameSize)
                            .frame(width: frameSize, height: frameSize)
                    }
                }
            }
        }
    }
    
    func borderOverlay(borderType: BorderType) -> some View {
        VStack(spacing: 0) {
            switch borderType {
            case .solid:
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .stroke(Color.black, lineWidth: 1)
            case .dotted:
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .butt, dash: [5]))
            case .semiDotted:
                RoundedRectangle(cornerSize: CGSize(width: 4, height: 4))
                    .stroke(Color.black, style: StrokeStyle(lineWidth: 1, lineCap: .butt, dash: [5, 10]))
            case .none:
                EmptyView()
            }
        }
    }
    
    func uuidLabel(nftTrait: NFT, frameSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            if isSecondaryTileUpperHalf {
                Spacer()
            }
            Text(UUID().uuidString)
                .font(.system(size: frameSize / 48, weight: .light, design: .default))
                .padding(frameSize / 8)
            if !isSecondaryTileUpperHalf {
                Spacer()
            }
        }
    }
}
    
extension NFTView {
        
    var topRow: [TileType]  {
        [.topLeft, .topInnerLeft, .topInnerRight, .topRight]
    }
    var innerTopRow: [TileType]  {
        [.innerTopLeft, .innerTopInnerLeft, .innerTopInnerRight, .innerTopRight]
    }
    var innerBottomRow: [TileType]  {
        [.innerBottomLeft, .innerBottomInnerLeft, .innerBottomInnerRight, .innerBottomRight]
    }
    var bottomRow: [TileType]  {
        [.bottomLeft, .bottomInnerLeft, .bottomInnerRight, .bottomRight]
    }
    
    var rows: [[TileType]] {
        [topRow, innerTopRow, innerBottomRow, bottomRow]
    }
    
    var isSecondaryTileUpperHalf: Bool {
        let upperTiles = [topRow, innerTopRow].flatMap {$0}
        return upperTiles.contains(nftTrait.secondaryTileSlot)
    }
}

struct NFTView_Previews: PreviewProvider {
    static var previews: some View {
        NFTView(nftTrait: NFTGenerator().randomNFT())
            .frame(width: 300, height: 300)
    }
}

struct SecondaryTile: View {
    
    var nftTrait: NFT
    var frameSize: CGFloat
    
    var body: some View {
        Image(systemName: nftTrait.secondarySymbol)
        .colorScheme(.light)
        .font(.system(size: frameSize/2, weight: .light, design: .default))
        .rotationEffect(Angle(degrees: Double(nftTrait.secondaryRotation.rawValue)))
        .frame(width: frameSize, height: frameSize)
        .background(nftTrait.secondaryBackgroundColor.color)
        .cornerRadius(4)
    }
}

struct SecondaryTile_Previews: PreviewProvider {
    static var previews: some View {
        SecondaryTile(nftTrait: NFTGenerator().randomNFT(), frameSize: 300)
            .background(Color.gray)
    }
}
