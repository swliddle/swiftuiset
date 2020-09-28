//
//  SetShapeView.swift
//  Set Game
//
//  Created by Steve Liddle on 9/19/20.
//

import SwiftUI

struct SetShapeView: View {
    var fillOpacity = 0.25
    var count = 1

    var body: some View {
        HStack {
            GeometryReader { geometry in
                setShapeBody(for: geometry.size)
            }
        }
    }

    private func setShapeBody(for size: CGSize) -> some View {
        let shapeType = Card.SymbolShape.capsule

        return HStack(spacing: spacing(for: size)) {
            ForEach(0..<count) { _ in
                ZStack {
                    SetShape(shapeType: shapeType).fill(Color.white)
                    SetShape(shapeType: shapeType).opacity(fillOpacity)
                    SetShape(shapeType: shapeType).stroke(lineWidth: lineWidth(for: size))
                }
                .aspectRatio(1/2, contentMode: .fit)
            }
        }
        .padding(padding(for: size))
        .offset(x: offset(for: size), y: 0)
    }

    // MARK: - Drawing constants

    private func lineWidth(for size: CGSize) -> CGFloat {
        scaledValue(0.015, for: size)
    }

    private func offset(for size: CGSize) -> CGFloat {
        (size.width
            - 2 * padding(for: size)
            - ((size.height - 2 * padding(for: size)) / 2) * CGFloat(count)
            - spacing(for: size) * (CGFloat(count) - 1))
            / 2
    }

    private func padding(for size: CGSize) -> CGFloat {
        scaledValue(0.125, for: size)
    }

    private func scaledValue(_ value: CGFloat, for size: CGSize) -> CGFloat {
        value * size.height
    }

    private func spacing(for size: CGSize) -> CGFloat {
        scaledValue(0.0625, for: size)
    }
}

struct SetShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SetShapeView(fillOpacity: 0)
                .foregroundColor(.purple)
                .cardify(selectionState: .selected)
                .aspectRatio(3/2, contentMode: .fit)
            SetShapeView(count: 2)
                .foregroundColor(.red)
                .cardify(selectionState: .matched)
                .aspectRatio(3/2, contentMode: .fit)
            SetShapeView(fillOpacity: 1, count: 3)
                .foregroundColor(.green)
                .cardify(selectionState: .mismatched)
                .aspectRatio(3/2, contentMode: .fit)
        }
        .foregroundColor(Color(red: 0.07, green: 0.07, blue: 0.07))
        .padding()
    }
}
