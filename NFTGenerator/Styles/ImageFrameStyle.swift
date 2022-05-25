//
//  ImageFrameStyle.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Foundation
import SwiftUI

enum ImageFrameStyleType: CGFloat {
    case standard = 36
    case large = 44
}

struct ImageFrameStyle: ViewModifier {

    let size: ImageFrameStyleType

    func body(content: Content) -> some View {
            return content
            .frame(width: size.rawValue, height: size.rawValue)
    }
}
