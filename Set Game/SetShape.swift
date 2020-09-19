//
//  SetShape.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

struct SetShape: Shape {
    var shapeType: SymbolShape

    func path(in rect: CGRect) -> Path {
        switch shapeType {
        case .capsule: return capsulePath(in: rect)
        case .diamond: return diamondPath(in: rect)
        case .squiggle: return squigglePath(in: rect)
        }
    }

    func capsulePath(in rect: CGRect) -> Path {
        let width = rect.width * 0.45
        let control = (4/3)*tan(CGFloat.pi/12)
        var path = Path()

        path.move(to: CGPoint(x: rect.midX - width, y: width))
        path.addCurve(
            to: CGPoint(x: rect.midX + width, y: width),
            control1: CGPoint(x: rect.midX - width, y: -width * control),
            control2: CGPoint(x: rect.midX + width, y: -width * control))
        path.addLine(to: CGPoint(x: rect.midX + width, y: rect.height - width))
        path.addCurve(
            to: CGPoint(x: rect.midX - width, y: rect.height - width),
            control1: CGPoint(x: rect.midX + width, y: rect.height + width * control),
            control2: CGPoint(x: rect.midX - width, y: rect.height + width * control))
        path.closeSubpath()

        return path
    }

    func diamondPath(in rect: CGRect) -> Path {
        let width = rect.height / 4
        var path = Path()

        path.move(   to: CGPoint(x: rect.midX,         y: 0))
        path.addLine(to: CGPoint(x: rect.midX + width, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX,         y: rect.height))
        path.addLine(to: CGPoint(x: rect.midX - width, y: rect.midY))
        path.closeSubpath()

        return path
    }

    func squigglePath(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 1040, y: 150))
        path.addCurve(to: CGPoint(x: 630, y: 540),
                      control1: CGPoint(x: 1124, y: 369),
                      control2: CGPoint(x: 897, y: 608))
        path.addCurve(to: CGPoint(x: 270, y: 530),
                      control1: CGPoint(x: 523, y: 513),
                      control2: CGPoint(x: 422, y: 420))
        path.addCurve(to: CGPoint(x: 50, y: 400),
                      control1: CGPoint(x: 96, y: 656),
                      control2: CGPoint(x: 54, y: 583))
        path.addCurve(to: CGPoint(x: 360, y: 120),
                      control1: CGPoint(x: 46, y: 220),
                      control2: CGPoint(x: 191, y: 97))
        path.addCurve(to: CGPoint(x: 890, y: 140),
                      control1: CGPoint(x: 592, y: 152),
                      control2: CGPoint(x: 619, y: 315))
        path.addCurve(to: CGPoint(x: 1040, y: 150),
                      control1: CGPoint(x: 953, y: 100),
                      control2: CGPoint(x: 1009, y: 69))

        path = path.offsetBy(dx: rect.minX - path.boundingRect.minX,
                             dy: rect.minY - path.boundingRect.minY)

        let scale: CGFloat = rect.height / path.boundingRect.width
        let transform = CGAffineTransform(scaleX: scale, y: scale)
            .rotated(by: CGFloat(Double.pi / 2))

        path = path.applying(transform)

        return path
            .offsetBy(dx: (rect.minX - path.boundingRect.minX + rect.width) / 2,
                      dy: rect.midY - path.boundingRect.midY)
    }
}

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
        let shapeType = SymbolShape.capsule

        return HStack(spacing: spacing(for: size)) {
            ForEach(0..<count) { _ in
                ZStack {
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
