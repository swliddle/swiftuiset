//
//  SoundPlayer.swift
//  Set Game
//
//  Created by Steve Liddle on 9/24/20.
//

import Foundation
import AVFoundation

enum SoundEffect: CaseIterable {
    case deal3
    case deal12
    case flip
    case gameOver
    case magicWand
    case pop
    case replace3
    case success
    case wrong

    var soundName: String {
        switch self {
        case .deal3:
            return "deal_three_cards.m4a"
        case .deal12:
            return "deal_twelve_cards.m4a"
        case .flip:
            return "84322__splashdust__flipcard.m4a"
        case .gameOver:
            return "325413__satchdev__cute-pixie-says-game-over.m4a"
        case .magicWand:
            return "magic_wand.m4a"
        case .pop:
            return "328118__greenvwbeetle__pop-7.m4a"
        case .replace3:
            return ""
        case .success:
            return "hand_bells_cluster.m4a"
        case .wrong:
            return "483598__raclure__wrong.m4a"
        }
    }
}

struct SoundPlayer {
    static var players = [String : AVAudioPlayer]()

    static func preparePlayers() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient)

        for soundEffect in SoundEffect.allCases {
            let soundName = soundEffect.soundName

            if let path = Bundle.main.path(forResource: soundName, ofType: nil) {
                do {
                    players[soundName] = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
                } catch {
                    print("Unable to load sound \(soundName)")
                }
            }
        }
    }

    static func play(_ soundEffect: SoundEffect) {
        if players.isEmpty {
            preparePlayers()
        }

        DispatchQueue.global().async {
            if let player = players[soundEffect.soundName] {
                player.play()
            }
        }
    }
}
