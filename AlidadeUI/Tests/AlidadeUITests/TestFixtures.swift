//
//  TestFixtures.swift
//  AlidadeUI
//
//  Created by Marquis Kurt on 24-05-2025.
//

import SwiftUI
import Testing

/// A short typealias to represent any error.
///
/// Intended to be used with `#expect(throws:)` to verify _any_ error is thrown.
typealias AnyError = any Error

extension Tag {
    /// A tag that refers to any views containing chips.
    @Tag static var chips: Self
}
