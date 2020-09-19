//
//  CardView.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

struct CardView: View {
    var card: SetGame.Card

    var body: some View {
        HStack {
            GeometryReader { geometry in
                setBody(for: geometry.size)
            }
        }
        .cardify(selectionState: card.selectionState)
        .aspectRatio(3/2, contentMode: .fit)
        .transition(AnyTransition.offset(randomLocationOffScreen))
    }

    private func setBody(for size: CGSize) -> some View {
        HStack(spacing: spacing(for: size)) {
            ForEach(0..<card.count) { _ in
                ZStack {
                    SetShape(shapeType: card.shape)
                        .foregroundColor(.white)
                    SetShape(shapeType: card.shape)
                        .opacity(card.pattern.opacity)
                    SetShape(shapeType: card.shape)
                        .stroke(lineWidth: lineWidth(for: size))
                }
                .foregroundColor(card.color.color)
                .aspectRatio(1/2, contentMode: .fit)
            }
        }
        .padding(padding(for: size))
        .offset(x: offset(for: size), y: 0)
    }

    // MARK: - Drawing constants

    private func lineWidth(for size: CGSize) -> CGFloat {
        scaledValue(0.02, for: size)
    }

    private func offset(for size: CGSize) -> CGFloat {
        (size.width
            - 2 * padding(for: size)
            - ((size.height - 2 * padding(for: size)) / 2) * CGFloat(card.count)
            - spacing(for: size) * (CGFloat(card.count) - 1))
            / 2
    }

    private func padding(for size: CGSize) -> CGFloat {
        scaledValue(0.125, for: size)
    }

    private var randomLocationOffScreen : CGSize {
        let r1 = CGFloat.random(in: -500...500)
        let r2 = CGFloat.random(in: -500...500)
        let size = UIScreen.main.bounds.size
        var x: CGFloat
        var y: CGFloat

        if r1 < 0 {
            x = r1 - size.width
        } else {
            x = size.width * 2 + r1
        }

        if r2 < 0 {
            y = r2 - size.width
        } else {
            y = size.width * 2 + r2
        }

        return CGSize(width: x, height: y)
    }

    private func scaledValue(_ value: CGFloat, for size: CGSize) -> CGFloat {
        value * size.height
    }

    private func spacing(for size: CGSize) -> CGFloat {
        scaledValue(0.0625, for: size)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        let game = SetGame()

        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
            ForEach(game.cards) { card in
                CardView(card: card)
            }
        }
        .padding(5)
    }
}
