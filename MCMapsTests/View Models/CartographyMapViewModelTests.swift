//
//  CartographyMapViewModelTests.swift
//  MCMaps
//
//  Created by Marquis Kurt on 04-02-2025.
//

import CubiomesKit
import Foundation
import SwiftUI
import Testing

@testable import Alidade

struct CartographyMapViewModelTests {
    typealias SizeClass = UserInterfaceSizeClass
    typealias Coordinate = Point3D<Int32>

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel))
    func viewModelInit() async throws {
        let viewModel = await CartographyMapViewModel()
        #expect(await viewModel.currentRoute == nil)
        #expect(await viewModel.displayCurrentRouteModally.wrappedValue == false)
        #expect(await viewModel.searchQuery.isEmpty)
        #expect(await viewModel.mapState == .loading)
        #expect(await viewModel.worldDimension == .overworld)
        #expect(await viewModel.worldRange.position == Coordinate(x: 0, y: 15, z: 0))
        #expect(await viewModel.worldRange.scale == Coordinate(x: 256, y: 1, z: 256))
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel))
    func viewModelPositionLabel() async throws {
        let viewModel = await CartographyMapViewModel()
        #expect(await viewModel.positionLabel == "X: 0, Z: 0")

        await MainActor.run {
            viewModel.worldRange.position = .init(cgPoint: CGPoint(x: 1847, y: 1847))
        }

        #expect(await viewModel.positionLabel == "X: 1847, Z: 1847")
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel), arguments: [("1.2", 123, true), ("fail", 123, false)])
    func viewModelRefreshMap(version: String, seed: Int64, shouldSucceed: Bool) async throws {
        let viewModel = await CartographyMapViewModel()
        let file = CartographyMapFile(map: .init(seed: seed, mcVersion: version, name: "Foo", pins: []))
        #expect(await viewModel.mapState == .loading)

        await viewModel.refreshMap(for: file)

        if shouldSucceed {
            guard case .success = await viewModel.mapState else {
                Issue.record("An error occurred.")
                return
            }
        } else {
            #expect(await viewModel.mapState == .unavailable)
        }
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel))
    func viewModelGoesToPosition() async throws {
        let viewModel = await CartographyMapViewModel()
        let file = CartographyMapFile(map: .sampleFile)
        #expect(await viewModel.mapState == .loading)
        #expect(await viewModel.worldRange.position == .init(x: 0, y: 15, z: 0))

        await viewModel.go(to: .init(x: 1847, y: 1847), relativeTo: file)
        #expect(await viewModel.worldRange.position == .init(x: 1847, y: 15, z: 1847))
        guard case .success = await viewModel.mapState else {
            Issue.record("An error occurred.")
            return
        }
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel), arguments: [
        (CartographyMapViewModel.CardinalDirection.north, Point3D<Int32>(x: 0, y: 15, z: -256)),
        (CartographyMapViewModel.CardinalDirection.west, Point3D<Int32>(x: -256, y: 15, z: 0)),
        (CartographyMapViewModel.CardinalDirection.east, Point3D<Int32>(x: 256, y: 15, z: 0)),
        (CartographyMapViewModel.CardinalDirection.south, Point3D<Int32>(x: 0, y: 15, z: 256))
    ])
    func viewModelGoesInDirection(
        direction: CartographyMapViewModel.CardinalDirection,
        coordinate: Point3D<Int32>
    ) async throws {
        let viewModel = await CartographyMapViewModel()
        let file = CartographyMapFile(map: .sampleFile)
        #expect(await viewModel.worldRange.position == .init(x: 0, y: 15, z: 0))

        await viewModel.go(inDirection: direction, relativeToFile: file)
        #expect(await viewModel.worldRange.position == coordinate)
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel))
    func viewModelSubmitsWorldChanges() async throws {
        let viewModel = await CartographyMapViewModel()
        let file = CartographyMapFile(map: .sampleFile)

        await MainActor.run {
            viewModel.currentRoute = .editWorld
        }

        await viewModel.submitWorldChanges(to: file)
        #expect(await viewModel.currentRoute == nil)
        guard case .success = await viewModel.mapState else {
            Issue.record("An error occurred.")
            return
        }
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel), .enabled(if: platform(is: .iOS)))
    func viewModelRouteBindingsMobile() async throws {
        let viewModel = await CartographyMapViewModel()
        await MainActor.run {
            viewModel.currentRoute = .editWorld
        }

        #expect(await viewModel.displayCurrentRouteAsInspector.wrappedValue == false)
        #expect(await viewModel.displayCurrentRouteModally.wrappedValue == false)
    }

    @Test(.timeLimit(.minutes(1)), .tags(.viewModel), .enabled(if: platform(is: .macOS)))
    func viewModelRouteBindingsDesktop() async throws {
        let viewModel = await CartographyMapViewModel()
        await MainActor.run {
            viewModel.currentRoute = .editWorld
        }
        
        #expect(await viewModel.displayCurrentRouteAsInspector.wrappedValue == false)
        #expect(await viewModel.displayCurrentRouteModally.wrappedValue == true)

        await viewModel.displayCurrentRouteModally.wrappedValue = false
        #expect(await viewModel.currentRoute == nil)
    }
}
