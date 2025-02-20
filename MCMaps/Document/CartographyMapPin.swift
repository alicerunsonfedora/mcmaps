//
//  Pin.swift
//  MCMaps
//
//  Created by Marquis Kurt on 03-02-2025.
//

import SwiftUI

/// A representation of a user-placed map pin.
struct CartographyMapPin: Codable, Hashable {
    enum Color: String, Codable, Hashable, CaseIterable {
        case red, orange, yellow, green, blue, indigo, brown, gray, pink

        var swiftUIColor: SwiftUI.Color {
            switch self {
            case .red:
                .red
            case .orange:
                .orange
            case .yellow:
                .yellow
            case .green:
                .green
            case .blue:
                .blue
            case .indigo:
                .indigo
            case .brown:
                .brown
            case .gray:
                .gray
            case .pink:
                .pink
            }
        }
    }

    /// The pin's world location.
    ///
    /// The X and Y coordinates correspond to the X and Z world coordinates, respectively.
    var position: CGPoint

    /// The pin's assigned name.
    var name: String

    /// The pin's color.
    ///
    /// Defaults to ``Color-swift.enum/blue`` if none was provided.
    var color: Color? = .blue

    /// The image files that are associated with this pin.
    ///
    /// Images consist of user-uploaded screenshots and are located in the ``CartographyMapFile/Keys/images``
    /// directory.
    var images: [String]? = []

    /// A user-written note that describes this pin.
    ///
    /// This is typically used to describe user-provided information such as the pin's significance, notable areas of
    /// interest, and what is nearby.
    var aboutDescription: String? = ""
}
