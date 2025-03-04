//
//  CartographyMapSidebar.swift
//  MCMaps
//
//  Created by Marquis Kurt on 01-02-2025.
//

import CubiomesKit
import SwiftUI

/// The sidebar content for the main app.
///
/// This will appear as the sheet content in the app's ``AdaptableSidebarSheetView``, and as the sidebar in the
/// ``CartographyMapSplitView``.
struct CartographyMapSidebar: View {
    @Environment(\.dismissSearch) private var dismissSearch

    /// The view model the sidebar will interact with.
    @Binding var viewModel: CartographyMapViewModel

    /// The file that the sidebar will read from and write to.
    ///
    /// Notably, the sidebar content will read from recent locations and the player-created pins.
    @Binding var file: CartographyMapFile

    private var searchBarPlacement: SearchFieldPlacement {
        #if os(macOS)
            return .sidebar
        #else
            return .navigationBarDrawer(displayMode: .always)
        #endif
    }

    var body: some View {
        Group {
            #if os(macOS)
                List(selection: $viewModel.currentRoute) {
                    listContents
                }
            #else
                List {
                    listContents
                }
            #endif
        }

        .frame(minWidth: 175, idealWidth: 200)
        .searchable(text: $viewModel.searchQuery, placement: searchBarPlacement, prompt: "Go To...")
        .animation(.default, value: searchResults)
        .onChange(of: viewModel.currentRoute) { _, newValue in
            switch newValue {
            case let .pin(_, pin):
                viewModel.go(to: pin.position, relativeTo: file)
            case let .recent(location):
                viewModel.go(to: location, relativeTo: file)
            default:
                break
            }
        }
    }

    private var listContents: some View {
        Group {
            if let results = searchResults, !viewModel.searchQuery.isEmpty {
                Group {
                    if let jumpToCoordinate = results.coordinates.first {
                        CartographyNamedLocationView(
                            name: "Jump Here",
                            location: jumpToCoordinate,
                            systemImage: "figure.run",
                            color: .accent
                        )
                        .onTapGesture {
                            withAnimation {
                                viewModel.go(to: jumpToCoordinate, relativeTo: file)
                                pushToRecentLocations(jumpToCoordinate)
                                viewModel.searchQuery = ""
                                if viewModel.currentRoute != nil {
                                    viewModel.currentRoute = nil
                                }
                            }
                        }
                    }

                    if !results.pins.isEmpty {
                        PinnedLibrarySection(pins: results.pins, viewModel: $viewModel, file: $file)
                    }

                    if !results.structures.isEmpty {
                        SearchedStructuresSection(
                            structures: results.structures,
                            viewModel: $viewModel,
                            file: $file
                        ) { jumpedToPin in
                            withAnimation {
                                pushToRecentLocations(jumpedToPin.position)
                                viewModel.searchQuery = ""
                            }
                        }
                    }
                }
            } else {
                defaultView
            }
        }
    }

    private var defaultView: some View {
        Group {
            if !file.map.pins.isEmpty {
                PinnedLibrarySection(pins: file.map.pins, viewModel: $viewModel, file: $file)
            }
            if file.map.recentLocations?.isEmpty == false {
                RecentLocationsListSection(viewModel: $viewModel, file: $file) { (position: CGPoint) in
                    viewModel.go(to: position, relativeTo: file)
                }
            }
        }
    }

    private var world: MinecraftWorld? {
        try? MinecraftWorld(version: file.map.mcVersion, seed: file.map.seed)
    }

    private var searchResults: CartographySearchService.SearchResult? {
        guard let world else { return nil }
        return CartographySearchService()
            .search(
                viewModel.searchQuery,
                world: world,
                file: file,
                currentPosition: viewModel.worldRange.position,
                dimension: viewModel.worldDimension
            )
    }

    func pushToRecentLocations(_ position: CGPoint) {
        if file.map.recentLocations == nil {
            file.map.recentLocations = [position]
            return
        }
        file.map.recentLocations?.append(position)
        if (file.map.recentLocations?.count ?? 0) > 15 {
            file.map.recentLocations?.remove(at: 0)
        }
        viewModel.currentRoute = .recent(position)
    }
}

#if DEBUG
    extension CartographyMapSidebar {
        var testHooks: TestHooks { TestHooks(target: self) }

        struct TestHooks {
            private let target: CartographyMapSidebar

            fileprivate init(target: CartographyMapSidebar) {
                self.target = target
            }

            var world: MinecraftWorld? {
                target.world
            }

            var searchResults: CartographySearchService.SearchResult? {
                target.searchResults
            }

            var searchBarPlacement: SearchFieldPlacement {
                target.searchBarPlacement
            }
        }
    }
#endif
