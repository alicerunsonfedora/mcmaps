//
//  CartographySearchServiceTests.swift
//  MCMaps
//
//  Created by Marquis Kurt on 08-02-2025.
//

import CubiomesKit
import Foundation
import Testing

@testable import Alidade

struct CartographySearchServiceTests {
    @Test("Empty query")
    func searchReturnsNoResultsOnEmptyQuery() async throws {
        let world = try MinecraftWorld(version: "1.21.3", seed: 123)
        let file = CartographyMapFile(map: .sampleFile)
        let service = CartographySearchService()

        let results = service.search("", world: world, file: file)
        #expect(results.isEmpty)
    }

    @Test(arguments: ["Spawn", "spawn", "Spa", "awn"])
    func searchReturnsPinsByName(query: String) async throws {
        let world = try MinecraftWorld(version: "1.21.3", seed: 123)
        let file = CartographyMapFile(map: .sampleFile)
        let service = CartographySearchService()

        let results = service.search(query, world: world, file: file)
        #expect(results.pins.count == 1)
        #expect(results.pins.first == .init(position: .zero, name: "Spawn"))
    }

    @Test(
        arguments: [
            ("1847, 1847", CGPoint(x: 1847, y: 1847)),
            ("-19, 20", CGPoint(x: -19, y: 20)),
            ("-11, -11", CGPoint(x: -11, y: -11)),
        ]
    )
    func searchReturnsJumpingLink(query: String, position: CGPoint) async throws {
        let world = try MinecraftWorld(version: "1.21.3", seed: 123)
        let file = CartographyMapFile(map: .sampleFile)
        let service = CartographySearchService()

        let results = service.search(query, world: world, file: file)
        #expect(results.coordinates.count == 1)
        #expect(results.coordinates.first == position)
    }
}
