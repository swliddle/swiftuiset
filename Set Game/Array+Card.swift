//
//  Array+Card.swift
//  Set Game
//
//  Created by Steve Liddle on 9/28/20.
//

import Foundation

extension Array where Element == Card {
    func indicesMatching(selectionState: Card.SelectionState) -> [Int] {
        self.indices.filter { self[$0].selectionState == selectionState }
    }
}
