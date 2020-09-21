//
//  SetGame.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import Foundation

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

struct SetGame {
    private let cardsPerSet = Card.maxSymbolCount
    private let matchScoreBase = 28
    private let desiredVisibleCardsCount = 12
    private let mismatchPenalty = 10
    private let hintPenalty = 10
    private let timeBreaksForMatch = [15.0, 30.0, 60.0, 90.0, 120.0]
    private let timeBonusFactor = 5

    var cards = [Card]()
    var visibleCards = [Card]()
    var hintCount = 0
    var score = 0
    var setCount = 0
    var timeStarted = Date()
    var timeOfLastSet = Date()

    init() {
        for shape in SymbolShape.allCases {
            for shade in SymbolPattern.allCases {
                for color in SymbolColor.allCases {
                    for count in Card.minSymbolCount...Card.maxSymbolCount {
                        cards.append(Card(shape: shape, pattern: shade, color: color, count: count))
                    }
                }
            }
        }

        cards.shuffle()
    }

    mutating func choose(_ card: Card) {
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

    func isASet(indices: [Int]) -> Bool {
        if indices.count != cardsPerSet {
            return false
        }

        let c1 = visibleCards[indices[0]]
        let c2 = visibleCards[indices[1]]
        let c3 = visibleCards[indices[2]]

        return dimensionIsASet(c1.shape, c2.shape, c3.shape)
            && dimensionIsASet(c1.color, c2.color, c3.color)
            && dimensionIsASet(c1.count, c2.count, c3.count)
            && dimensionIsASet(c1.pattern, c2.pattern, c3.pattern)
    }

    mutating func markHint(indices: [Int]) {
        deselectAll()

        indices.forEach {
            visibleCards[$0].selectionState = .hinted
        }

        score -= hintPenalty
        hintCount += 1
    }

    // MARK: - Private helpers

    private mutating func checkForSet(with chosenIndex: Int) {
        let matchedIndices = visibleCards.indices.filter { visibleCards[$0].selectionState == .matched }
        let mismatchedIndices = visibleCards.indices.filter { visibleCards[$0].selectionState == .mismatched }
        let selectedIndices = visibleCards.indices.filter { visibleCards[$0].selectionState == .selected }

        if mismatchedIndices.count > 0 {
            mismatchedIndices.forEach { index in
                visibleCards[index].selectionState = .none
            }
        } else if matchedIndices.count > 0 {
            replaceCurrentSet()
        } else if selectedIndices.count >= cardsPerSet {
            if isASet(indices: selectedIndices) {
                scoreANewSet()

                selectedIndices.forEach { index in
                    visibleCards[index].selectionState = .matched
                }
            } else {
                score -= mismatchPenalty

                selectedIndices.forEach { index in
                    visibleCards[index].selectionState = .mismatched
                }
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

    private func dimensionIsASet<E: Equatable>(_ c1: E, _ c2: E, _ c3: E) -> Bool {
        c1 == c2 && c2 == c3 ||
        c1 != c2 && c2 != c3 && c1 != c3
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
        for index in stride(from: visibleCards.count - 1, through: 0, by: -1) {
            if visibleCards[index].selectionState == .matched {
                replaceCard(at: index)
            }
        }
    }

    private mutating func scoreANewSet() {
        setCount += 1
        score += matchScoreBase - (visibleCards.count / cardsPerSet)

        let elapsedTime = Date().timeIntervalSince(timeOfLastSet)

        for index in timeBreaksForMatch.indices {
            if elapsedTime < timeBreaksForMatch[index] {
                score += (timeBreaksForMatch.count - index) * timeBonusFactor
                break
            }
        }

        timeOfLastSet = Date()
    }

    // MARK: - Nested Card

    struct Card: Identifiable {
        var selectionState = SelectionState.none
        var shape: SymbolShape
        var pattern: SymbolPattern
        var color: SymbolColor
        var count: Int
        var id = nextIdValue()

        static let minSymbolCount = 1
        static let maxSymbolCount = 3

        private static var nextId = 0

        private static func nextIdValue() -> Int {
            nextId += 1

            return nextId
        }
    }
}
