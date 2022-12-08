//
//  AppleWatchGameApp.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import SwiftUI

@main
struct AppleWatchGame_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
                .environmentObject(GameLogic())
        }
    }
}
