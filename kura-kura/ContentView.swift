//
//  ContentView.swift
//  kura-kura
//
//  Created by idraki on 13/08/2024.
//

import SwiftUI
import Foundation

enum StokenError: Error, LocalizedError {
    case stokenNotInstalled
    case stokenUnableToGenerateCode
    
    var errorDescription: String? {
        switch self {
        case .stokenNotInstalled:
            return NSLocalizedString("Stoken is not installed. Please install it with Homebrew.", comment: "")
        case .stokenUnableToGenerateCode:
            return NSLocalizedString(("Stoken unable to generate the code"), comment: "")
        }
    }
}

class SettingsWindowController: NSWindowController {
    override func windowDidLoad() {
        super.windowDidLoad()
        // Additional setup if needed
    }
    
    func closeWindow() {
        self.window?.close()
    }
}

struct ContentView: View {
    @State private var vpn: Process?
    @State private var token: String = ""
    @State private var isLoading = false
    @State private var isConnected = false
    @State private var errorMessage: [String] = []
    @State private var logMessage: [String] = []
    @State private var isSettingsWindowOpen = false
    @State private var sudoPassword: String = ""
    @State private var passcode = UserDefaults.standard.string(forKey: "passcode") ?? ""
    @State private var hostURL = UserDefaults.standard.string(forKey: "hostURL") ?? ""
    @State private var user = UserDefaults.standard.string(forKey: "username") ?? ""
    @State private var password = UserDefaults.standard.string(forKey: "password") ?? ""
    @State private var useSlice = UserDefaults.standard.bool(forKey: "useSlice")
    @State private var urls = UserDefaults.standard.string(forKey: "urls") ?? ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button(action: {
                    showSettingsWindow()
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .frame(width: 16, height: 16)
                    Text("Settings")
                }
                .padding()
                .disabled(isLoading || isConnected)
            }.background(Color(NSColor.gridColor))
            
            Spacer()
            
            VStack {
                ScrollView {
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 12) {
                        VStack() {
                            Text("Sudo Password")
                                .font(.headline)
                            
                            TextField("Enter password", text: $sudoPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .disabled(isConnected)
                        }
                        .frame(width: 200)
                        
                        Button(action: {
                            if isConnected {
                                stopVpn()
                            } else {
                                prepareConfig()
                            }
                        }) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .scaleEffect(0.5)
                            } else {
                                Text(isConnected ? "Disconnect" : "Connect")
                            }
                        }
                        .disabled(sudoPassword.isEmpty || isLoading)
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 8) {
                        if !errorMessage.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(errorMessage, id: \.self) { message in
                                    HStack(spacing: 4) {
                                        Image(systemName: "xmark.seal.fill")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.red)
                                        Text(message)
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                        
                        if !logMessage.isEmpty && errorMessage.isEmpty {
                            VStack(alignment: .leading) {
                                ForEach(logMessage, id: \.self) { message in
                                    HStack(alignment: .center, spacing: 4) {
                                        Image(systemName: "checkmark.seal.fill")
                                            .resizable()
                                            .frame(width: 16, height: 16)
                                            .foregroundColor(.green)
                                        Text(message)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
                VStack {
                    HStack(alignment: .center) {
                        Text("Status:")
                        Text(isConnected ? "Connected" : "Disconnected")
                            .foregroundColor(
                                isConnected ? .green : .red)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(NSColor.windowBackgroundColor))
            }
        }
        .frame(maxWidth: 400, maxHeight: .infinity, alignment: .top)
    }
    
    func showSettingsWindow() {
        if let existingWindow = NSApp.windows.first(where: { $0.title == "Settings" }) {
            existingWindow.makeKeyAndOrderFront(nil)
            return
        }
        
        let settingsWindowController = SettingsWindowController(windowNibName: NSNib.Name("SettingsWindow"))
        
        let settingsWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 200),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        settingsWindow.title = "Settings"
        settingsWindow.center()
        settingsWindow.setFrameAutosaveName("SettingsWindow")
        settingsWindow.contentView = NSHostingView(
            rootView: SettingsView(
                tokenPasscode: $passcode,
                hostURL: $hostURL,
                username: $user,
                password: $password,
                useSlice: $useSlice,
                urls: $urls,
                windowController: settingsWindowController
            )
        )
        settingsWindowController.window = settingsWindow
        settingsWindow.makeKeyAndOrderFront(nil)
    }
    
    func getUserShell() -> String {
        // Retrieve the SHELL environment variable
        let shell = ProcessInfo.processInfo.environment["SHELL"]
        
        // Provide a default shell if the environment variable is not set
        return shell ?? "/bin/sh"
    }
    
    func runShell(_ command: String) throws -> String {
        let task = Process()
        
        task.launchPath = getUserShell()
        task.arguments = ["--login", "-c", command]
        
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)
        
        return output ?? ""
    }
    
    func runVpn(_ command: String) {
        vpn = Process()
        
        vpn?.launchPath = getUserShell()
        vpn?.arguments = ["--login", "-c", command]
        
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        
        vpn?.standardOutput = outputPipe
        vpn?.standardError = errorPipe
        
        outputPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let outputString = String(data: data, encoding: .utf8), !outputString.isEmpty {
                print("VPN Output: \(outputString)")
                
                if outputString.contains("Got CONNECT response: HTTP/1.1 200 OK") {
                    isConnected = true
                    isLoading = false
                }
            }
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { fileHandle in
            let data = fileHandle.availableData
            if let errorString = String(data: data, encoding: .utf8), !errorString.isEmpty {
                print("VPN Output: \(errorString)")
                
                if errorString.contains("Got CONNECT response: HTTP/1.1 200 OK") {
                    isConnected = true
                    isLoading = false
                }
                
                if errorString.contains("stdin") {
                    print("VPN Error: \(errorString)")
                    isLoading = false
                    stopVpn()
                }
            }
        }
        
        do {
            try vpn?.run()
        } catch {
            print("Error starting process: \(error)")
            isConnected = false
        }
    }
    
    func stopVpn() {
        vpn?.terminate()
        isConnected = false
    }
    
    func checkData() -> [String] {
        var message: [String] = []
        
        if hostURL.isEmpty {
            message.append("Host URL is empty. Please add it in the settings")
        } else {
            logMessage.append("Host URL is set")
        }
        
        if passcode.isEmpty {
            message.append("Token passocde is empty. Please add it in the settings")
        } else {
            logMessage.append("Token passcode is set")
        }
        
        if user.isEmpty {
            message.append("Username is empty. Please add it in the settings")
        } else {
            logMessage.append("Username is set")
        }
        
        if password.isEmpty {
            message.append("Password is empty. Please add it in the settings")
        } else {
            logMessage.append("Password is set")
        }
        
        return message
    }
    
    func runStokenCommand() throws -> String {
        do {
            let checkStoken = try runShell("which stoken")
            
            if checkStoken.isEmpty || checkStoken.contains("not found") {
                errorMessage.append("Stoken is not installed. Please install it with Homebrew.")
                throw StokenError.stokenNotInstalled
            } else {
                print("Stoken path: \(checkStoken)")
                
                // get the token code
                let token = try runShell("stoken tokencode -p \(passcode)")
                
                if !token.isEmpty {
                    return token
                } else {
                    throw StokenError.stokenUnableToGenerateCode
                }
            }
        } catch {
            print("Failed to check/install stoken: \(error.localizedDescription)")
            throw error
        }
    }
    
    func connectVpn() throws -> String {
        do {
            let checkOpenConnect = try runShell("which openconnect")
            
            if checkOpenConnect.isEmpty || checkOpenConnect.contains("not found") {
                errorMessage.append("OpenConnect aren't installed. Installed it with Homebrew./n https://formulae.brew.sh/formula/openconnect")
                throw StokenError.stokenNotInstalled
            } else {
                print("OpenConnect path: \(checkOpenConnect)")
                
                var vpnSliceCommand = ""
                
                if useSlice {
                    let checkSlice = try runShell("which vpn-slice ")
                    
                    if checkSlice.isEmpty || checkSlice.contains("not found") {
                        errorMessage.append("vpn-slice aren't installed. Installed it with Homebrew./n https://formulae.brew.sh/formula/vpn-slice")
                        throw StokenError.stokenNotInstalled
                    } else {
                        // check if urls have been defined
                        if urls.isEmpty {
                            errorMessage.append("VPN Slice are enabled, but URLs for VPN slicing are not set. Please add it in the settings.")
                            throw StokenError.stokenNotInstalled
                        } else {
                            vpnSliceCommand = "-s 'vpn-slice \(urls)'"
                            
                            logMessage.append("VPN slice is checked")
                            logMessage.append("VPN slice URLS have been set")
                        }
                    }
                }
                
                // append the passcode
                let passPin = "\(passcode)\(token)"
                
                print("sudoPassword: \(sudoPassword)")
                print("passPin: \(passPin)")
                print("password: \(password)")
                print("user: \(user)")
                print("user: \(hostURL)")
                print("use slice?: \(useSlice)")
                
                let command = """
                (echo '\(sudoPassword)'; echo \(passPin); echo '\(password)') | sudo -S openconnect --user=\(user) \(hostURL) \(vpnSliceCommand)
                """
                
                // the command now run continously
                runVpn(command)
                
                return ""
            }
        } catch {
            print("Failed to check/install stoken: \(error.localizedDescription)")
            throw error
        }
    }
    
    func prepareConfig() {
        isLoading = true
        errorMessage = []
        logMessage = []
        
        do {
            // check if necessary data already set
            let dataMissing = checkData()
            
            if dataMissing.isEmpty {
                // check and get the token
                let tokenCode = try runStokenCommand()
                
                if !tokenCode.isEmpty {
                    token = tokenCode.trimmingCharacters(in: .whitespacesAndNewlines)
                    logMessage.append("Token generated: \(token)")
                    
                    try connectVpn()
                }
                
            } else {
                errorMessage = dataMissing
                isLoading = false
            }
        } catch {
            isLoading = false
            print("Error preparing config: \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
