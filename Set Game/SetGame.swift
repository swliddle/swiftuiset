//
//  SetGame.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import Foundation

struct SetGame {

    // MARK: - Constants

    private let cardsPerSet = Card.maxSymbolCount
    private let dealPenalty = 10
    private let desiredVisibleCardsCount = 12
    private let matchScoreBase = 28
    private let maxScoreValueOfSet = 27
    private let mismatchPenalty = 10
    private let hintPenalty = 10
    let timeBreaksForMatch = [15.0, 30.0, 45.0, 60.0, 75.0]
    private let timeBonusFactor = 5

    // MARK: - Properties

    var cards = [Card]()
    var hintCount = 0
    var isMarkedSetVisible = false
    var isMismatchedSetVisible = false
    var lastTimeStarted: Date?
    var pastTimeElapsed: TimeInterval = 0
    var score = 0
    var setCount = 0
    var timeOfLastSet = Date()
    var unnecessaryDealCount = 0
    var visibleCards = [Card]()

    // MARK: - Computed properties

    var timeElapsed: TimeInterval {
        pastTimeElapsed - (lastTimeStarted?.timeIntervalSince(Date()) ?? 0)
    }

    // MARK: - Initialization

    init() {
        for shape in Card.SymbolShape.allCases {
            for shade in Card.SymbolPattern.allCases {
                for color in Card.SymbolColor.allCases {
                    for count in Card.minSymbolCount...Card.maxSymbolCount {
                        cards.append(Card(shape: shape, pattern: shade, color: color, count: count))
                    }
                }
            }
        }

        cards.shuffle()
    }

    // MARK: - Methods

    mutating func assessDealPenalty() {
        unnecessaryDealCount += 1
        score -= dealPenalty
    }

    mutating func choose(_ card: Card) {
        isMarkedSetVisible = false
        isMismatchedSetVisible = false

        if let chosenIndex = visibleCards.firstIndex(matching: card) {
            clearHint()

            switch visibleCards[chosenIndex].selectionState {
            case .none, .hinted:
                visibleCards[chosenIndex].selectionState = .selected
                checkForSet(with: chosenIndex)
            case .selected:
                visibleCards[chosenIndex].selectionState.toggle()
            case .matched:
                replaceCurrentSet()
            case .mismatched:
                deselectAll()
            }
        }
    }

    mutating func dealOneCard() {
        if let card = cards.first {
            visibleCards.append(card)
            cards.remove(at: 0)
        }
    }

    mutating func dealThreeCards() {
        for _ in 0..<cardsPerSet {
            dealOneCard()
        }
    }

    func isValidSet(indices: [Int]) -> Bool {
        if indices.count != cardsPerSet {
            return false
        }

        let c1 = visibleCards[indices[0]]
        let c2 = visibleCards[indices[1]]
        let c3 = visibleCards[indices[2]]

        return dimensionIsSetCandidate(c1.shape, c2.shape, c3.shape)
            && dimensionIsSetCandidate(c1.color, c2.color, c3.color)
            && dimensionIsSetCandidate(c1.count, c2.count, c3.count)
            && dimensionIsSetCandidate(c1.pattern, c2.pattern, c3.pattern)
    }

    mutating func markHint(indices: [Int]) {
        deselectAll()

        indices.forEach {
            visibleCards[$0].selectionState = .hinted
            score -= hintPenalty
        }

        hintCount += 1
    }

    mutating func startTimer() {
        if lastTimeStarted == nil {
            lastTimeStarted = Date()
        }
    }

    mutating func stopTimer() {
        if let lastTimeStarted = lastTimeStarted {
            pastTimeElapsed += Date().timeIntervalSince(lastTimeStarted)
            self.lastTimeStarted = nil
        }
    }

    // MARK: - Private helpers

    private mutating func checkForSet(with chosenIndex: Int) {
        let matchedIndices = visibleCards.indicesMatching(selectionState: .matched)
        let mismatchedIndices = visibleCards.indicesMatching(selectionState: .mismatched)
        let selectedIndices = visibleCards.indicesMatching(selectionState: .selected)

        if mismatchedIndices.count > 0 {
            mismatchedIndices.forEach { index in
                visibleCards[index].selectionState = .none
            }
        } else if matchedIndices.count > 0 {
            replaceCurrentSet()
        } else if selectedIndices.count >= cardsPerSet {
            if isValidSet(indices: selectedIndices) {
                scoreNewSet(marking: selectedIndices)
            } else {
                scoreMismatch(marking: selectedIndices)
            }
        }
    }

    private mutating func clearHint() {
        visibleCards.indices.forEach { index in
            if visibleCards[index].selectionState == .hinted {
                visibleCards[index].selectionState = .none
            }
        }
    }

    private mutating func deselectAll() {
        visibleCards.indices.forEach { index in
            visibleCards[index].selectionState = .none
        }
    }

    private func dimensionIsSetCandidate<E: Equatable>(_ c1: E, _ c2: E, _ c3: E) -> Bool {
        c1 == c2 && c2 == c3 ||
        c1 != c2 && c2 != c3 && c1 != c3
    }

    private mutating func markCards(_ indices: [Int], _ state: Card.SelectionState) {
        indices.forEach { index in
            visibleCards[index].selectionState = state
        }
    }

    private mutating func markSetVisible(using indices: [Int]) {
        timeOfLastSet = Date()
        isMarkedSetVisible = true
        markCards(indices, .matched)
    }

    private mutating func replaceCard(at index: Int) {
        if let card = cards.first, visibleCards.count <= desiredVisibleCardsCount {
            visibleCards[index] = card
            cards.remove(at: 0)
        } else {
            visibleCards.remove(at: index)
        }
    }

    private mutating func replaceCurrentSet() {
        // We need to traverse the array backwards because we are modifying it
        for index in stride(from: visibleCards.count - 1, through: 0, by: -1) {
            if visibleCards[index].selectionState == .matched {
                replaceCard(at: index)
            }
        }
    }

    private mutating func scoreMismatch(marking indices: [Int]) {
        score -= mismatchPenalty
        isMismatchedSetVisible = true
        markCards(indices, .mismatched)
    }

    private mutating func scoreNewSet(marking indices: [Int]) {
        let scoreValueOfSet = matchScoreBase - (visibleCards.count / cardsPerSet)

        setCount += 1
        score += scoreValueOfSet

        let elapsedTime = Date().timeIntervalSince(timeOfLastSet)

        for index in timeBreaksForMatch.indices {
            if elapsedTime < timeBreaksForMatch[index] {
                score += (timeBreaksForMatch.count - index) * timeBonusFactor
                    * scoreValueOfSet / maxScoreValueOfSet
                break
            }
        }

        markSetVisible(using: indices)
    }
}
