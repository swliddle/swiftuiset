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
        withAnimation(.easeInOut(duration: animationDuration)) {
            game.choose(card)
        }
    }

    func dealCards(quantity: Int) {
        for i in 0..<quantity {
            withAnimation(Animation.easeInOut(duration: animationDuration).delay(Double(i) * dealingAnimationDuration)) {
                game.dealOneCard()
            }
        }
    }

    func showHint() {
        let cards = visibleCards

        for i in cards.indices {
            for j in cards.indices {
                if j != i {
                    for k in cards.indices {
                        if k != i && k != j && game.isASet(indices: [i, j, k]) {
                            withAnimation(.easeIn(duration: animationDuration)) {
                                game.markHint(indices: [i, j, k])
                            }

                            return
                        }
                    }
                }
            }
        }
    }

    func resetGame() {
        withAnimation {
            game = SetGame()
        }

        dealCards(quantity: initialDeckSize)
    }

    // MARK: - Constants

    private let animationDuration = 0.4
    private let dealingAnimationDuration = 0.2
    private let initialDeckSize = 12
}
