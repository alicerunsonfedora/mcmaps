//
//  ContentView.swift
//  MCMaps
//
//  Created by Marquis Kurt on 31-01-2025.
//

import CubiomesKit
import Observation
import SwiftUI

enum CartographyMapViewState: Equatable {
    case loading
    case success(Data)
    case unavailable
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dismiss) private var dismissWindow
    @Binding var file: CartographyMapFile
    @State private var viewModel = CartographyMapViewModel()
    
    var body: some View {
        Group {
#if os(macOS)
            CartographyMapSplitView(viewModel: $viewModel, file: $file)
                .toolbar {
                    toolbarContent
                }
#else
            AdaptableSidebarSheetView(isPresented: $viewModel.displaySidebarSheet) {
                CartographyMapView(state: viewModel.state)
                    .edgesIgnoringSafeArea(.all)
            } sheet: {
                CartographyMapSidebarSheet(viewModel: $viewModel, file: $file) {
                    toolbarContent
                }
            }
#endif
        }
        .navigationTitle(file.map.name)
        .animation(.default, value: file.map.recentLocations)
        .animation(.default, value: viewModel.state)
        .task {
            await viewModel.refreshMap(file.map.seed, for: file.map.mcVersion)
        }
        .onChange(of: viewModel.worldDimension) { _, newValue in
            Task { await viewModel.refreshMap(file.map.seed, for: file.map.mcVersion) }
        }
#if os(iOS)
        .onAppear {
            hideNavigationBar()
        }
#endif
        .sheet(isPresented: $viewModel.displayChangeSeedForm) {
            NavigationStack {
                MapCreatorForm(worldName: $file.map.name, mcVersion: $file.map.mcVersion, seed: $file.map.seed)
                    .formStyle(.grouped)
                    .navigationTitle("Update World")
#if os(iOS)
                    .navigationBarBackButtonHidden()
#endif
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                viewModel.submitWorldChanges(
                                    seed: file.map.seed,
                                    mcVersion: file.map.mcVersion,
                                    horizontalSizeClass)
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") {
                                viewModel.cancelWorldChanges(horizontalSizeClass)
                            }
                        }
                    }
            }
        }
        .sheet(isPresented: $viewModel.displayNewPinForm) {
#if os(iOS)
            viewModel.displaySidebarSheet = horizontalSizeClass == .compact
#endif
        } content: {
            NavigationStack {
                PinCreatorForm(location: viewModel.locationToPin) { pin in
                    file.map.pins.append(pin)
                }
                .formStyle(.grouped)
#if os(iOS)
                .navigationBarBackButtonHidden()
#endif
            }
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        Group {
#if os(iOS)
            ToolbarTitleMenu {
                Picker(selection: $viewModel.worldDimension) {
                    Label("Overworld", systemImage: "tree").tag(MinecraftWorld.Dimension.overworld)
                    Label("Nether", systemImage: "flame").tag(MinecraftWorld.Dimension.nether)
                    Label("End", systemImage: "sparkles").tag(MinecraftWorld.Dimension.end)
                } label: { }
                    .labelStyle(.titleAndIcon)
                    .pickerStyle(.palette)
                Button {
                    viewModel.presentWorldChangesForm()
                } label: {
                    Label("Update World", systemImage: "tree")
                }
            }
            ToolbarItem(placement: .navigation) {
                Button {
                    viewModel.displaySidebarSheet = false
                    dismissWindow()
                } label: {
                    Label("Back", systemImage: "chevron.left")
                }
                .fontWeight(.bold)
            }
#endif
            
            ToolbarItem {
                Button {
                    Task {
                        await viewModel.refreshMap(file.map.seed, for: file.map.mcVersion)
                    }
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            
#if os(macOS)
            ToolbarItem {
                Button {
                    viewModel.presentWorldChangesForm()
                } label: {
                    Label("Update World", systemImage: "info.circle")
                }
            }
            
            ToolbarItem(placement: .secondaryAction) {
                Picker(selection: $viewModel.worldDimension) {
                    Label("Overworld", systemImage: "tree").tag(MinecraftWorld.Dimension.overworld)
                    Label("Nether", systemImage: "flame").tag(MinecraftWorld.Dimension.nether)
                    Label("End", systemImage: "sparkles").tag(MinecraftWorld.Dimension.end)
                } label: {
                    Label("Dimension", systemImage: "map")
                }
                .pickerStyle(.palette)
            }
#endif
        }
    }
}

#Preview {
    @Previewable @State var file = CartographyMapFile(map: .sampleFile)
    ContentView(file: $file)
}
