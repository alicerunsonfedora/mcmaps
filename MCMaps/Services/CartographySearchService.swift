//
//  CartographySearchService.swift
//  MCMaps
//
//  Created by Marquis Kurt on 08-02-2025.
//

import CubiomesKit
import Foundation

/// A service that searches and filters content in Minecraft worlds and `.mcmap` files.
class CartographySearchService {
    /// The type of query used to initiate searches.
    typealias Query = String

    /// A structure representing a set of results the search service has returned.
    struct SearchResult: Sendable, Equatable {
        /// The pins that matched a given query.
        var pins: [MCMapManifestPin]

        /// The coordinates that matched a given query.
        ///
        /// This is typically populated when the query represents a coordinate that can be quickly jumped to, such as
        /// if the player provided a coordinate query.
        var coordinates: [CGPoint]

        /// Nearby biomes that matched within the specified radius.
        var biomes: [MCMapManifestPin]

        /// Nearby structures that matched within the specified radius.
        var structures: [MCMapManifestPin]

        /// Whether the search results are completely empty.
        var isEmpty: Bool {
            pins.isEmpty && coordinates.isEmpty && structures.isEmpty && biomes.isEmpty
        }

        init() {
            self.pins = []
            self.coordinates = []
            self.structures = []
            self.biomes = []
        }
    }

    private enum Constants {
        nonisolated(unsafe) static let coordinateRegex = /(-?\d+), (-?\d+)/
        static let defaultSearchRadius: Int32 = 20
    }

    /// The search radius for the search service to use when searching for structures.
    ///
    /// The default search radius is twenty blocks wide.
    var searchRadius: Int32 = Constants.defaultSearchRadius

    /// Creates a search service.
    init() {
        self.searchRadius = Constants.defaultSearchRadius
    }

    /// Searches the Minecraft world and file for information, given a query.
    /// - Parameter query: The query to search the respective world and file for.
    /// - Parameter world: THe world to search against.
    /// - Parameter file: The file to search against.
    /// - Parameter currentPosition: The current position to search from. Defaults to the origin.
    /// - Parameter dimension: The Minecraft world dimension to search in. Defaults to the overworld.
    func search(
        _ query: Query, world: MinecraftWorld,
        file: CartographyMapFile,
        currentPosition: Point3D<Int32> = .zero,
        dimension: MinecraftWorld.Dimension = .overworld
    ) async -> SearchResult {
        var results = SearchResult()

        if let matches = query.matches(of: Constants.coordinateRegex).first?.output {
            if let x = Double(matches.1), let y = Double(matches.2) {
                results.coordinates.append(CGPoint(x: x, y: y))
            }
        }

        for pin in file.manifest.pins {
            guard pin.name.lowercased().contains(query.lowercased()) else {
                continue
            }
            results.pins.append(pin)
        }

        if let structure = MinecraftStructure(string: query) {
            let foundStructures = world.findStructures(
                ofType: structure,
                at: currentPosition,
                inRadius: searchRadius,
                dimension: dimension
            )
            for foundStruct in foundStructures {
                results.structures
                    .append(
                        MCMapManifestPin(
                            position: CGPoint(x: Double(foundStruct.x), y: Double(foundStruct.z)),
                            name: structure.name,
                            color: structure.pinColor)
                    )
            }

            let cgPointOrigin = CGPoint(x: Double(currentPosition.x), y: Double(currentPosition.z))
            results.structures.sort { first, second in
                first.position
                    .manhattanDistance(to: cgPointOrigin) < second.position.manhattanDistance(to: cgPointOrigin)
            }
        }

        results.biomes = searchBiomes(
            query: query,
            mcVersion: file.manifest.worldSettings.version,
            world: world,
            pos: currentPosition,
            dimension: dimension
        )

        return results
    }

    private func searchBiomes(
        query: String, mcVersion: String, world: MinecraftWorld, pos: Point3D<Int32>,
        dimension: MinecraftWorld.Dimension
    ) -> [MCMapManifestPin] {
        guard let biome = MinecraftBiome(localizedString: query, mcVersion: mcVersion) else {
            return []
        }
        let foundBiomes = world.findBiomes(
            ofType: biome,
            at: pos,
            inRadius: 8000,
            dimension: dimension
        )
        let name = biome.localizedString(for: world.version)
        var biomes = foundBiomes.map { foundBiome in
            MCMapManifestPin(
                position: CGPoint(x: Double(foundBiome.x), y: Double(foundBiome.z)),
                name: name)
        }

        let cgPointOrigin = CGPoint(x: Double(pos.x), y: Double(pos.z))
        biomes.sort { first, second in
            first.position
                .manhattanDistance(to: cgPointOrigin) < second.position.manhattanDistance(to: cgPointOrigin)
        }
        return biomes
    }
}
