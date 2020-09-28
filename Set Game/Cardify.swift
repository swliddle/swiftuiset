//
//  Cardify.swift
//  Concentration
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

struct Cardify: ViewModifier {
    var selectionState: Card.SelectionState

    func body(content: Content) -> some View {
        GeometryReader { geometry in
            ZStack {
                cardBody(for: geometry.size, content: content)
            }
        }
    }

    @ViewBuilder
    private func cardBody(for size: CGSize, content: Content) -> some View {
        let radius = cornerRadius(for: size)

        RoundedRectangle(cornerRadius: radius).fill(fillColor(for: selectionState))
        RoundedRectangle(cornerRadius: radius).stroke()
        content
    }

    private func cornerRadius(for size: CGSize) -> CGFloat {
        size.width * 0.05
    }

    private func fillColor(for state: Card.SelectionState) -> Color {
        switch state {
        case .selected:
            return Color.yellow
        case .matched:
            return Color(red: 0.6, green: 0.9, blue: 0.6)
        case .mismatched:
            return Color(red: 1.0, green: 0.6, blue: 0.6)
        case .hinted:
            return Color(red: 1.0, green: 0.8, blue: 1.0)
        case .none:
            return Color.white
        }
    }
}

struct Cardify_Previews: PreviewProvider {
    static var previews: some View {
        let card = Card(shape: .squiggle, pattern: .striped, color: .purple, count: 3, id: 1)

        return CardView(card: card)
            .foregroundColor(.black)
            .padding()
    }
}

extension View {
    func cardify(selectionState: Card.SelectionState) -> some View {
        modifier(Cardify(selectionState: selectionState))
    }
}
