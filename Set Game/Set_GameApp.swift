//
//  Set_GameApp.swift
//  Set Game
//
//  Created by Steve Liddle on 9/17/20.
//

import SwiftUI

@main
struct Set_GameApp: App {
    var body: some Scene {
        WindowGroup {
            SetGameView(setGame: SetGameViewModel())
        }
    }
}
