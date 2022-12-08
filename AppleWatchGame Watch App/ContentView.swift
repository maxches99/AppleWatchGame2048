//
//  ContentView.swift
//  AppleWatchGame Watch App
//
//  Created by Максим Чесников on 07.12.2022.
//

import SwiftUI

struct ContentView: View {
    
    var gameLogic: GameLogic = GameLogic()
    
    var body: some View {
        VStack {
            Spacer()
            GameView()
                .environmentObject(gameLogic)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
