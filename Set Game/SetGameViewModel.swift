//
//  SetGameViewModel.swift
//  Set Game
//
//  Created by Steve Liddle on 9/18/20.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    @Published private var game = SetGame()

    // MARK: - Model access

    var hiddenCardCount: Int {
        game.cards.count
    }

    var setCount: Int {
        game.setCount
    }

    var visibleCards: [SetGame.Card] {
        game.visibleCards
    }

    // MARK: - Intents

    func choose(_ card: SetGame.Card) {
        game.choose(card)
    }

    func dealThreeMoreCards() {
        game.dealThreeCards()
    }

    func resetGame() {
        game = SetGame()
    }
}
