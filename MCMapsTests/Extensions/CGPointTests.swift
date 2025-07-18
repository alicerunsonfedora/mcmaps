//
//  CGPointTests.swift
//  MCMaps
//
//  Created by Marquis Kurt on 04-03-2025.
//

import Foundation
import Testing

@testable import Alidade

struct PointSet {
    let source: CGPoint
    let destination: CGPoint
}

struct CGPointTests {
    @Test(arguments: [
        (PointSet(source: .init(x: 1, y: 1), destination: .init(x: 4, y: 5)), 7.0),
        (PointSet(source: .init(x: 1, y: 2), destination: .init(x: 3, y: 3)), 3.0),
        (PointSet(source: .init(x: 4, y: 2), destination: .init(x: 4, y: 2)), 0.0),
    ])
    func manhattanDistance(points: PointSet, distance: Double) async throws {
        let diff = points.source.manhattanDistance(to: points.destination)
        #expect(diff == distance)
    }

    @Test func accessibilityReadout() async throws {
        let point = CGPoint(x: 1847, y: 1847)
        #expect(point.accessibilityReadout == "1,847, 1,847")
    }

    @Test func rounded() async throws {
        let point = CGPoint(x: 1847.118, y: 1963.9913)
        #expect(point.rounded() == CGPoint(x: 1847.0, y: 1964.0))
    }
}
