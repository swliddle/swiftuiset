//
//  SymbolColor+Extension.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

extension Card.SymbolColor {
    var color: Color {
        switch self {
        case .green:
            return .green
        case .purple:
            return .purple
        case .red:
            return .red
        }
    }
}

extension Card.SymbolPattern {
    var opacity: Double {
        switch self {
        case .open:
            return 0
        case .striped:
            return 0.25
        case .solid:
            return 1
        }
    }
}
