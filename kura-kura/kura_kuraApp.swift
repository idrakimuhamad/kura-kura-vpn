//
//  kura_kuraApp.swift
//  kura-kura
//
//  Created by idraki on 13/08/2024.
//

import SwiftUI

@main
struct kura_kuraApp: App {
    @State private var passcode = UserDefaults.standard.string(forKey: "passcode") ?? ""
    @State private var hostURL = UserDefaults.standard.string(forKey: "hostURL") ?? ""
    @State private var user = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var password = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var urls = UserDefaults.standard.array(forKey: "urls") as? [String] ?? []
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: 400, minHeight: 200, maxHeight: 400)
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(after: CommandGroupPlacement.appInfo) {
                Divider()
                Button("Settings") {
                    showSettingsWindow()
                }
                .keyboardShortcut(",", modifiers: .command)
            }
        }
    }
    
    func showSettingsWindow() {
        DispatchQueue.main.async {
            // Check if the settings window already exists
            if let existingWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
                existingWindow.makeKeyAndOrderFront(nil)
                return
            }
            
            // Initialize the SettingsWindowController
            let settingsWindowController = SettingsWindowController(windowNibName: NSNib.Name("SettingsWindow"))
            
            let settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 400),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered, defer: false
            )
            settingsWindow.title = "Settings"
            settingsWindow.center()
            settingsWindow.setFrameAutosaveName("SettingsWindow")
            
            // Create and set the content view
            let settingsView = SettingsView(
                tokenPasscode: $passcode,
                hostURL: $hostURL,
                username: $user,
                password: $password,
                urls: $urls,
                windowController: settingsWindowController
            )
            
            let hostingView = NSHostingView(rootView: settingsView)
            settingsWindow.contentView = hostingView
            settingsWindowController.window = settingsWindow
            
            settingsWindow.makeKeyAndOrderFront(nil)
        }
    }
    
}
