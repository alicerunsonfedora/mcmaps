//
//  RecentLocationsListSection.swift
//  MCMaps
//
//  Created by Marquis Kurt on 31-01-2025.
//

import SwiftUI

/// A section used to display recently visited locations.
///
/// This is normally invoked from ``CartographyMapSidebar`` and is almost never instantiated on its own.
struct RecentLocationsListSection: View {
    /// The view model the sidebar will interact with.
    @Binding var viewModel: CartographyMapViewModel

    /// The file that the sidebar will read from and write to.
    @Binding var file: CartographyMapFile

    private var recentLocations: [CGPoint] {
        file.map.recentLocations ?? []
    }

    /// A handler that executes when the player has requested to go to a specific location.
    var goToPosition: ((CGPoint) -> Void)?

    var body: some View {
        Section("Recents") {
            ForEach(Array(recentLocations.enumerated().reversed()), id: \.offset) { (idx, pos) in
                CartographyNamedLocationView(
                    name: "Location",
                    location: pos,
                    systemImage: "location.fill",
                    color: .gray
                )
                .tag(CartographyRoute.recent(pos))
                #if os(iOS)
                    .onTapGesture {
                        goToPosition?(pos)
                    }
                    .swipeActions(edge: .leading) {
                        NavigationLink(value: CartographyRoute.createPin(pos)) {
                            Label("Pin...", systemImage: "mappin")
                        }
                        .tint(.accentColor)
                    }
                    .swipeActions(edge: .trailing) {
                        Button {
                            file.map.recentLocations?.remove(at: idx)
                        } label: {
                            Label("Remove from Recents", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                #endif
                .contextMenu {
                    #if os(iOS)
                        NavigationLink(value: CartographyRoute.createPin(pos)) {
                            Label("Pin...", systemImage: "mappin")
                        }
                    #else
                        Button {
                            viewModel.currentRoute = .createPin(pos)
                        } label: {
                            Label("Pin...", systemImage: "mappin")
                        }
                    #endif
                    Button {
                        goToPosition?(pos)
                    } label: {
                        Label("Go Here", systemImage: "location")
                    }
                    Button("Remove from Recents", role: .destructive) {
                        file.map.recentLocations?.remove(at: idx)
                    }
                }
                #if os(iOS)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                #endif
            }
            .onDelete { indexSet in
                file.map.recentLocations?.remove(atOffsets: indexSet)
            }
        }
    }
}
