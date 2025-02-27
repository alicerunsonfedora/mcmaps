//
//  WorldDimensionPickerView.swift
//  MCMaps
//
//  Created by Marquis Kurt on 13-02-2025.
//

import CubiomesKit
import SwiftUI

/// A picker view used to select a Minecraft world dimension.
///
/// The picker exposes a SwiftUI `Picker` type, so any additional picker modifiers will apply. On macOS, this is
/// displayed as an inline menu.
struct WorldDimensionPickerView: View {
    /// The selection representing the world dimension.
    @Binding var selection: MinecraftWorld.Dimension

    var body: some View {
        Picker("Dimension", selection: $selection) {
            Label("Overworld", systemImage: "tree")
                .tag(MinecraftWorld.Dimension.overworld)
            Label("Nether", systemImage: "flame")
                .tag(MinecraftWorld.Dimension.nether)
            Label("End", systemImage: "sparkles")
                .tag(MinecraftWorld.Dimension.end)
        }
    }
}
