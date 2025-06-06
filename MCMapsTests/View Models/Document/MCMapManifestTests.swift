//
//  MCMapManifestTests.swift
//  MCMaps
//
//  Created by Marquis Kurt on 25-05-2025.
//

import Foundation
import Testing

@testable import Alidade

struct MCMapManifestTests {
    @Test func emptyTagSetPre_V2() async throws {
        let manifest = MCMapManifest_v1(
            seed: 0,
            mcVersion: "1.21",
            name: "Foo",
            pins: [MCMapManifestPin(position: .zero, name: "Spawn")]
        )
        let upgradedManifest = try MCMapManifest_v2(from: manifest)

        #expect(upgradedManifest.getAllAvailableTags().isEmpty)
    }

    @Test func allAvailableTags() async throws {
        let manifest = MCMapManifest(
            manifestVersion: 2,
            name: "My World",
            worldSettings: MCMapManifestWorldSettings(version: "1.21", seed: 123),
            pins: [
                MCMapManifestPin(position: .zero, name: "Spawn", tags: ["Autocreated"]),
                MCMapManifestPin(position: CGPoint(x: 1847, y: 1847), name: "Augenwaldburg", tags: ["Forest", "Base"]),
            ],
            recentLocations: []
        )

        #expect(manifest.getAllAvailableTags() == ["Autocreated", "Forest", "Base"])
    }
}
