//
//  TimeInterval+CompactString.swift
//  Set Game
//
//  Created by Steve Liddle on 9/21/20.
//

import Foundation

extension TimeInterval {
    var compactString: String {
        let intervalInSeconds = Int(self)

        let hours = intervalInSeconds / 3600
        let minutes = (intervalInSeconds % 3600) / 60
        let seconds = (intervalInSeconds % 3600) % 60

        var string = hours > 0 ? "\(hours)" : ""

        if minutes > 0 && hours > 0 {
            string = "\(string):\(leftPadZero(minutes))"
        } else if minutes > 0 {
            string = "\(minutes)"
        }

        if string != "" {
            string = "\(string):\(leftPadZero(seconds))"
        } else {
            string = "\(seconds)"
        }

        return string
    }

    private func leftPadZero(_ value: Int) -> String {
        value > 9 ? "\(value)" : "0\(value)"
    }
}
