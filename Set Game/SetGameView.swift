//
//  SetGameView.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

struct SetGameView: View {
    @ObservedObject var setGame: SetGameViewModel

    @State private var players = [SoundPlayer]()

    var body: some View {
        VStack {
            if setGame.hiddenCardCount <= 0
                && setGame.setCount > 0
                && !setGame.isSetAvailable {
                Spacer()
                Text("No more sets. Game over!")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .padding(50)
                Spacer()
            } else {
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

                Spacer()
            }

            ControlsAndScoreView(setGame: setGame)
        }
        .onAppear {
            setGame.dealCards(quantity: 12)
            setGame.startTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            setGame.startTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            setGame.stopTimer()
        }
    }

    private func columns(for size: CGSize) -> [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 5),
              count: columnCount(for: size))
    }

    private func columnCount(for size: CGSize) -> Int {
        var columns = 2
        var spacingWidth: CGFloat
        var width: CGFloat
        var rows: Int

        repeat {
            // Starting with a minimum of 3 columns, see how many
            // rows will be needed.  Keep increasing the column
            // count until the cards all fit in the space available.
            columns += 1
            spacingWidth = CGFloat((columns - 1) * 5)
            width = (size.width - spacingWidth) / CGFloat(columns)
            rows = (setGame.visibleCards.count + columns - 1) / columns
        } while heightRequired(for: rows, of: width) > size.height

        return columns
    }

    private func heightRequired(for rows: Int, of width: CGFloat) -> CGFloat {
        let spacingHeight = CGFloat((rows - 1) * 5)

        return 2 * width / 3 * CGFloat(rows) + spacingHeight
    }
}

struct ControlsAndScoreView: View {
    @ObservedObject var setGame: SetGameViewModel
    @Environment(\.horizontalSizeClass) var sizeClass

    var body: some View {
        if sizeClass == .compact {
            VStack {
                HStack {
                    buttonsView()
                }
                .padding()

                HStack {
                    scoreDetailsView()
                }
                .padding([.leading, .trailing])
            }
        } else {
            HStack {
                buttonsView()
                Spacer()
                scoreDetailsView()
            }
            .padding([.leading, .trailing, .bottom])
        }
    }

    @ViewBuilder
    private func buttonsView() -> some View {
        Button("Deal 3") {
            setGame.dealCards(quantity: 3)
        }
        .disabled(setGame.hiddenCardCount <= 0)

        Spacer()
        Button("New Game") {
            setGame.resetGame()
            setGame.startTimer()
        }

        Spacer()
        Button("Hint") {
            setGame.showHint()
        }
        .disabled(!setGame.isSetAvailable)

        Spacer()
        Text("Score: \(setGame.score)")
    }

    @ViewBuilder
    private func scoreDetailsView() -> some View {
        if setGame.gameIsOver {
            Text("High score: \(setGame.highScore)")
        } else {
            Text("Elapsed: \(setGame.timeElapsed.compactString)")
            Spacer()
            Text("Bonus time: \(setGame.bonusTimeLeft.compactString)")
                .onAppear() {
                    let _ = setGame.timer
                }
        }

        Spacer()

        if setGame.setCount == 1 {
            Text("1 Set")
        } else {
            Text("\(setGame.setCount) Sets")
        }
    }
}

struct SetGameView_Previews: PreviewProvider {
    static var previews: some View {
        SetGameView(setGame: SetGameViewModel())
    }
}
