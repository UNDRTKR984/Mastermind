//
//  MemorizeApp.swift
//  Memorize
//
//  Created by Matt Vogel on 1/11/21.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        let game = MasterMindGame()
        WindowGroup {
            ContentView(viewModel: game)
        }
    }
}
