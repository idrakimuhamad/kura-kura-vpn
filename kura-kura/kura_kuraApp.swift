//
//  kura_kuraApp.swift
//  kura-kura
//
//  Created by idraki on 13/08/2024.
//

import SwiftUI

@main
struct kura_kuraApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 200, maxHeight: 500)
        }
        .windowResizability(.contentSize)
    }
}
