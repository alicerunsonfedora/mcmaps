//
//  CGPoint+Manhattan.swift
//  MCMaps
//
//  Created by Marquis Kurt on 16-02-2025.
//

import Foundation

extension CGPoint {
    /// Returns the distance between two points using the Manhattan/taxicab algorithm.
    ///
    /// This is typically used to calculate the distance between two locations by a measure of Minecraft blocks rather
    /// than a raw distance.
    /// 
    /// - Parameter other: The endpoint to get the distance to from the current point.
    func manhattanDistance(to other: CGPoint) -> Double {
        let deltaX = self.x - other.x
        let deltaY = self.y - other.y
        return abs(deltaX) + abs(deltaY)
    }

    /// A human-readable readout for accessibility purposes.
    var accessibilityReadout: String {
        let xVal = Int(x)
        let yVal = Int(y)
        return String(localized: "\(xVal), \(yVal)")
    }

    /// Rounds the components of the point.
    /// - Parameter rule: The rule to use when rounding. Defaults to `.toNearestOrAwayFromZero`.
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> Self {
        CGPoint(x: self.x.rounded(rule), y: self.y.rounded(rule))
    }
}
