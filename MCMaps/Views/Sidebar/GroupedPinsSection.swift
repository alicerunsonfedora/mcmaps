//
//  SearchedStructuresSection.swift
//  MCMaps
//
//  Created by Marquis Kurt on 16-02-2025.
//

import CubiomesKit
import SwiftUI

/// A section used to display grouped pins that are being searched for.
///
/// This is normally invoked from ``CartographyMapSidebar`` and is almost never instantiated on its own.
struct GroupedPinsSection: View {
    /// The name of the grouped pin section.
    var name: LocalizedStringKey = "Structures"

    /// The structures from the search results.
    var pins: [CartographyMapPin]

    /// The view model the sidebar will interact with.
    @Binding var viewModel: CartographyMapViewModel

    /// The file that the sidebar will read from and write to.
    ///
    /// Notably, the sidebar content will read from recent locations and the player-created pins.
    @Binding var file: CartographyMapFile

    /// A completion handler that executes when the player has jumped to a pin.
    var jumpedToPin: ((CartographyMapPin) -> Void)?

    var body: some View {
        Section(name) {
            Group {
                if pins.isEmpty {
                    Text("No results found.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(pins, id: \.self) { pin in
                        CartographyNamedLocationView(pin: pin)
                            .coordinateDisplayMode(
                                .relative(
                                    CGPoint(
                                        x: Double(viewModel.worldRange.position.x),
                                        y: Double(viewModel.worldRange.position.z)))
                            )
                            .onTapGesture {
                                viewModel.go(to: pin.position, relativeTo: file)
                                jumpedToPin?(pin)
                            }
                            .contextMenu {
                                Button {
                                    viewModel.go(to: pin.position, relativeTo: file)
                                    jumpedToPin?(pin)
                                } label: {
                                    Label("Go Here", systemImage: "location")
                                }
                                Button {
                                    viewModel.currentRoute = .createPin(pin.position)
                                } label: {
                                    Label("Pin...", systemImage: "mappin")
                                }
                            }
                            #if os(iOS)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                            #endif
                    }
                }
            }
        }
    }
}
