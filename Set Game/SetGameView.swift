//
//  SetGameView.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var setGame: SetGameViewModel

    func columns(for size: CGSize) -> [GridItem] {
        var columns = 3
        var width = size.width / CGFloat(columns)
        var rows = (setGame.visibleCards.count + columns - 1) / columns

        while 2 * width / 3 * CGFloat(rows) > size.height {
            columns += 1
            width = size.width / CGFloat(columns)
            rows = (setGame.visibleCards.count + columns - 1) / columns
        }

        return Array(repeating: GridItem(.flexible()), count: columns)
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                ScrollView {
                    LazyVGrid(columns: columns(for: geometry.size)) {
                        ForEach(setGame.visibleCards) { card in
                            CardView(card: card)
                                .onTapGesture {
                                    withAnimation(.easeInOut) {
                                        setGame.choose(card)
                                    }
                                }
                        }
                    }
                    .padding([.leading, .trailing], 5)
                }
            }

            Spacer()

            HStack {
                Button("Deal 3") {
                    setGame.dealThreeMoreCards()
                }
                .disabled(setGame.hiddenCardCount <= 0)
                Spacer()
                Button("New Game") {
                    setGame.resetGame()
                }
                Spacer()
                Text("\(setGame.setCount) Sets")
            }
            .padding()
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(setGame: SetGameViewModel())
    }
}
