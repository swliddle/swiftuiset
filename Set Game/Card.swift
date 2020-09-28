//
//  Card.swift
//  Set Game
//
//  Created by Steve Liddle on 9/28/20.
//

import Foundation

struct Card: Identifiable {

    // MARK: - Nested enums

    enum SelectionState {
        case none
        case selected
        case matched
        case mismatched
        case hinted

        mutating func toggle() {
            self = self == .none ? .selected : .none
        }
    }

    enum SymbolShape: CaseIterable {
        case capsule
        case diamond
        case squiggle
    }

    enum SymbolPattern: CaseIterable {
        case open
        case striped
        case solid
    }

    enum SymbolColor: CaseIterable {
        case green
        case purple
        case red
    }

    // MARK: - Properties

    var selectionState = SelectionState.none
    var shape: SymbolShape
    var pattern: SymbolPattern
    var color: SymbolColor
    var count: Int
    var id = nextIdValue()

    // MARK: - Static properties

    static let minSymbolCount = 1
    static let maxSymbolCount = 3

    private static var nextId = 0

    // MARK: - Private helpers

    private static func nextIdValue() -> Int {
        // This is a simplistic implementation, and we really don't need a
        // complex variation at this point.  But if we were saving the app
        // state to disk and then restoring it, the nextId value would
        // need to be saved along with the rest of the game state.
        nextId += 1

        return nextId
    }
}
