//
//  Route.swift
//  AlidadeUI Playground
//
//  Created by Marquis Kurt on 25-05-2025.
//

import SwiftUI

enum Route: Hashable, CaseIterable {
    case chipTextField
    case finiteColorPicker
    case formHeader
    case inlineBanner
    case namedLocation
    case namedTextField
}

extension Route {
    var name: String {
        switch self {
        case .chipTextField:
            "Chip Text Field"
        case .finiteColorPicker:
            "Finite Color Picker"
        case .formHeader:
            "Form Header"
        case .inlineBanner:
            "Inline Banner"
        case .namedLocation:
            "Named Location"
        case .namedTextField:
            "Named Text Field"
        }
    }

    var symbol: String {
        switch self {
        case .chipTextField:
            "tag"
        case .finiteColorPicker:
            "swatchpalette"
        case .formHeader:
            "rectangle.grid.3x1"
        case .inlineBanner:
            "bubble"
        case .namedLocation:
            "mappin"
        case .namedTextField:
            "character.textbox"
        }
    }

    var navigationLink: some View {
        NavigationLink(value: self) {
            Label(self.name, systemImage: self.symbol)
        }
    }
}
