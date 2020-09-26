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

    var timeElapsed: TimeInterval {
        game.timeElapsed
    }

    var soundPlayer = SoundPlayer()

    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if let maxBonus = self.game.timeBreaksForMatch.last, self.timeElapsed < maxBonus {
                self.bonusTimeLeft = maxBonus - self.timeElapsed
            } else {
                self.bonusTimeLeft = 0
            }
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

        SoundPlayer.play(.pop)

        if game.isMismatchedSetVisible {
            SoundPlayer.play(.wrong)
        }

        if game.isMarkedSetVisible {
            SoundPlayer.play(.success)
        }

        dealCardsToAllowSet()

        let currentScore = score

        if currentScore > highScore {
            UserDefaults.standard.set(score,
                                      forKey: Constant.keyHighScore)
            highScore = currentScore
        }

        if hiddenCardCount <= 0 && setCount > 0 && !isSetAvailable {
            SoundPlayer.play(.gameOver)
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

        if quantity >= initialDeckSize {
            SoundPlayer.play(.deal12)
        } else if quantity >= 3 {
            SoundPlayer.play(.deal3)
        }
    }

    func resetGame() {
        withAnimation {
            game = SetGame()
        }

        dealCards(quantity: initialDeckSize)
        dealCardsToAllowSet(delayCount: initialDeckSize)
    }

    func showHint() {
        let matchedIndices = visibleCards.indices.filter { visibleCards[$0].selectionState == .matched }

        if matchedIndices.count > 0 {
            withAnimation {
                game.choose(visibleCards[matchedIndices[0]])
            }
        }

        SoundPlayer.play(.hint)

        if let availableSet = firstAvailableSet(),
           let randomIndex = availableSet.randomElement() {
            withAnimation(.easeIn(duration: animationDuration)) {
                game.markHint(indices: [randomIndex])
            }
        }
    }

    func startTimer() {
        game.startTimer()
    }

    func stopTimer() {
        game.stopTimer()
    }

    // MARK: - Helpers

    private func dealCardsToAllowSet(delayCount: Int = 0) {
        while !isSetAvailable && hiddenCardCount > 0 {
            dealCards(quantity: Constant.cardsPerDeal, with: delayCount)
        }
    }

    private func firstAvailableSet() -> [Int]? {
        let cards = visibleCards

        // Just a note of caution here: this is a four-level loop.
        // It could get pretty expensive to evaluate if the number of
        // cards grows large.  3 to the 4th power is only 81, but 12
        // to the 4th is 20,736 and 81 to the 4th is 43,046,721.  So
        // you want to be a little careful with what you choose to do
        // in a four-level loop.
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
    private let dealingAnimationDuration = 0.33
    private let initialDeckSize = 12
}
