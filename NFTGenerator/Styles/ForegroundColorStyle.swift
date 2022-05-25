//
//  ForegroundColorStyle.swift
//  NFTGenerator (iOS)
//
//  Created by YES 2011 Limited on 08/04/2022.
//

import Foundation
import SwiftUI

enum ForegroundColorStyleType {
    case standard, mid, light, lightest
}

extension ForegroundColorStyleType {
    
    var opacity: Double {
        switch self {
        case .standard: return 0.9
        case .mid: return 0.8
        case .light: return 0.5
        case .lightest: return 0.01
        }
    }
}

struct ForegroundColorStyle: ViewModifier {

    @Environment(\.colorScheme) var colorScheme
    let type: ForegroundColorStyleType

    func body(content: Content) -> some View {
            return content
            .foregroundColor(colorScheme == .dark ? .white : .black.opacity(type.opacity))
    }
}
