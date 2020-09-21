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

        return Array(repeating: GridItem(.flexible(), spacing: 5), count: columns)
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                LazyVGrid(columns: columns(for: geometry.size), spacing: 5) {
                    ForEach(setGame.visibleCards) { card in
                        CardView(card: card)
                            .onTapGesture {
                                withAnimation {
                                    setGame.choose(card)
                                }
                            }
                    }
                }
                .padding([.leading, .trailing], 5)
            }

            if setGame.hiddenCardCount <= 0
                && setGame.setCount > 0
                && !setGame.isSetAvailable {
                Spacer()
                Text("No more sets.\nGame over!")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding(50)
            }

            Spacer()

            HStack {
                Button("Deal 3") {
                    setGame.dealCards(quantity: 3)
                }
                .disabled(setGame.hiddenCardCount <= 0)

                Spacer()
                Button("New Game") {
                    setGame.resetGame()
                }

                Spacer()
                Button("Hint") {
                    setGame.showHint()
                }
                .disabled(!setGame.isSetAvailable)

                Spacer()
                Text("\(setGame.setCount) Set\(setGame.setCount == 1 ? "" : "s")")
            }
            .padding()
        }
        .onAppear {
            setGame.dealCards(quantity: 12)
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(setGame: SetGameViewModel())
    }
}
