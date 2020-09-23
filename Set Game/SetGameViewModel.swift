//
//  SetGameViewModel.swift
//  Set Game
//
//  Created by Steve Liddle on 9/18/20.
//

import SwiftUI

class SetGameViewModel: ObservableObject {
    struct Constant {
        static let cardsPerDeal = 3
        static let keyHighScore = "highscore"
    }

    @Published private var game = SetGame()
    @Published var bonusTimeLeft: TimeInterval = 0
    @Published var highScore = UserDefaults.standard.integer(forKey: Constant.keyHighScore)
    @Published var timeElapsed: TimeInterval = 0

    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            let timeElapsed = Date().timeIntervalSince(self.game.timeOfLastSet)

            if let maxBonus = self.game.timeBreaksForMatch.last, timeElapsed < maxBonus {
                self.bonusTimeLeft = maxBonus - timeElapsed
            } else {
                self.bonusTimeLeft = 0
            }

            self.timeElapsed = Date().timeIntervalSince(self.game.timeStarted)
        }
    }

    // MARK: - Model access

    var gameIsOver: Bool {
        hiddenCardCount <= 0 && setCount > 0 && !isSetAvailable
    }

    var hiddenCardCount: Int {
        game.cards.count
    }

    var isSetAvailable: Bool {
        if let _ = firstAvailableSet() {
            return true
        }

        return false
    }

    var score: Int {
        return game.score
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

        dealCardsToAllowSet()

        let currentScore = score

        if currentScore > highScore {
            UserDefaults.standard.set(score,
                                      forKey: Constant.keyHighScore)
            highScore = currentScore
        }
    }

    func dealCards(quantity: Int, with delayCount: Int = 0) {
        if visibleCards.count >= initialDeckSize && isSetAvailable {
            game.assessDealPenalty()
        }

        for i in 0..<quantity {
            withAnimation(
                Animation.easeInOut(
                    duration: animationDuration
                )
                .delay(Double(i + delayCount) * dealingAnimationDuration)
            ) {
                game.dealOneCard()
            }
        }
    }

    func showHint() {
        let matchedIndices = visibleCards.indices.filter { visibleCards[$0].selectionState == .matched }

        if matchedIndices.count > 0 {
            withAnimation {
                game.choose(visibleCards[matchedIndices[0]])
            }
        }

        if let availableSet = firstAvailableSet(),
           let randomIndex = availableSet.randomElement() {
            withAnimation(.easeIn(duration: animationDuration)) {
                game.markHint(indices: [randomIndex])
            }
        }
    }

    func resetGame() {
        withAnimation {
            game = SetGame()
        }

        dealCards(quantity: initialDeckSize)
        dealCardsToAllowSet(delayCount: initialDeckSize)
    }

    // MARK: - Helpers

    private func dealCardsToAllowSet(delayCount: Int = 0) {
        while !isSetAvailable && hiddenCardCount > 0 {
            dealCards(quantity: Constant.cardsPerDeal, with: delayCount)
        }
    }

    private func firstAvailableSet() -> [Int]? {
        let cards = visibleCards

        for i in cards.indices {
            for j in cards.indices {
                if j != i {
                    for k in cards.indices {
                        if k != i && k != j && game.isASet(indices: [i, j, k]) {
                            return [i, j, k]
                        }
                    }
                }
            }
        }

        return nil
    }

    // MARK: - Constants

    private let animationDuration = 0.4
    private let dealingAnimationDuration = 0.2
    private let initialDeckSize = 12
}
