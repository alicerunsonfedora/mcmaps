//
//  TestFixtures.swift
//  MCMaps
//
//  Created by Marquis Kurt on 27-02-2025.
//

import Testing

extension Tag {
    /// A tag for tests that work directly with a document or other I/O.
    @Tag static var document: Self

    /// A tag for tests that work with view models.
    @Tag static var viewModel: Self

    /// A tag for tests under the legacy user interface.
    @Tag static var legacyUI: Self

    /// A tag for tests under the Red Window user interface.
    @Tag static var redWindow: Self
}

enum TargetPlatform {
    case macOS
    case iOS
}

func platform(is target: TargetPlatform) -> Bool {
    #if os(macOS)
        return target == .macOS
    #else
        return target == .iOS
    #endif
}

/// Run a test that is known to break under the Red Window redesign.
func withBreakingRedWindow(
    comment: Comment? = nil, sourceLocation: SourceLocation = #_sourceLocation, try closure: () throws -> Void
) rethrows {
    #if RED_WINDOW
        withKnownIssue(comment, isIntermittent: true, sourceLocation: sourceLocation, closure)
    #else
        #expect(throws: Never.self, sourceLocation: sourceLocation) {
            try closure()
        }
    #endif
}
