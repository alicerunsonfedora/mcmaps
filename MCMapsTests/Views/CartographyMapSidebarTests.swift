//
//  CartographyMapSidebarTests.swift
//  MCMaps
//
//  Created by Marquis Kurt on 26-02-2025.
//

import SwiftUI
import Testing
import ViewInspector

@testable import Alidade

@MainActor
struct CartographyMapSidebarTests {
    @Test func pushToRecentLocations() throws {
        let file = Binding(wrappedValue: CartographyMapFile(withManifest: .sampleFile))
        let viewModel = Binding(wrappedValue: CartographyMapViewModel())
        let sidebar = CartographyMapSidebar(viewModel: viewModel, file: file)

        sidebar.pushToRecentLocations(.zero)
        #expect(file.wrappedValue.manifest.recentLocations?.count == 1)
        #expect(viewModel.wrappedValue.currentRoute == .recent(.zero))
    }

    @Test func pushToRecentLocationsPurgesRecent() throws {
        var filledFile = CartographyMapFile(withManifest: .sampleFile)
        filledFile.manifest.recentLocations = Array(repeating: .zero, count: 15)
        let file = Binding(wrappedValue: filledFile)
        let viewModel = Binding(wrappedValue: CartographyMapViewModel())
        let sidebar = CartographyMapSidebar(viewModel: viewModel, file: file)

        sidebar.pushToRecentLocations(.init(x: 11, y: 11))
        #expect(file.wrappedValue.manifest.recentLocations?.count == 15)
        #expect(file.wrappedValue.manifest.recentLocations?.last == .init(x: 11, y: 11))
    }
}

// FIXME: Bad! Bad! Stop the JavaScript bullshit! Bad!

extension SearchFieldPlacement: @retroactive Equatable {
    public static func == (lhs: SearchFieldPlacement, rhs: SearchFieldPlacement) -> Bool {
        return String(describing: lhs) == String(describing: rhs)
    }
}
