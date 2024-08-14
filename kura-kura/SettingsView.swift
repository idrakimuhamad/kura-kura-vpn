import SwiftUI

struct SettingsView: View {
    @Binding var tokenPasscode: String
    @Binding var hostURL: String
    @Binding var username: String
    @Binding var password: String
    @Binding var useSlice: Bool
    @Binding var urls: String
    
    @State private var isPasswordVisible: Bool = false
    @State private var isFocusedOnUrl: Bool = false
    
    var windowController: SettingsWindowController?
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack(spacing: 8) {
                    VStack(alignment: .leading) {
                        VStack(alignment: .leading) {
                            Text("Token Passcode")
                                .font(.headline)
                            
                            TextField("Enter passcode", text: $tokenPasscode)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Text("Stoken must be install manually through Homebrew.")
                                .font(.caption)
                            Text("Follow the set up usage here: https://github.com/stoken-dev/stoken?tab=readme-ov-file#usage")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color(NSColor.gridColor))
                        
                        VStack(alignment: .leading) {
                            Text("VPN Host URL")
                                .font(.headline)
                            TextField("Host URL", text: $hostURL)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        .background(Color(NSColor.gridColor))
                        
                        VStack(alignment: .leading) {
                            Text("User")
                                .font(.headline)
                            TextField("User", text: $username)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding()
                        .background(Color(NSColor.gridColor))
                        
                        VStack(alignment: .leading) {
                            Text("Password")
                                .font(.headline)
                            
                            HStack() {
                                if isPasswordVisible {
                                    TextField("Password", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(size: 15))
                                        .frame(height: 30)
                                } else {
                                    SecureField("Password", text: $password)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .font(.system(size: 15))
                                        .frame(height: 30)
                                }
                                
                                Button(action: {
                                    isPasswordVisible.toggle()
                                }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash" : "eye")
                                        .foregroundColor(.gray)
                                        .padding(4)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color(NSColor.gridColor))
                        
                        VStack(alignment: .leading) {
                            HStack {
                                VStack(alignment: .leading, spacing: 16) {
                                    Toggle(isOn: $useSlice) {
                                        Text("Use URL Splicing")
                                    }
                                    .toggleStyle(CheckboxToggleStyle())
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    
                                    if useSlice {
                                        VStack(alignment: .leading) {
                                            Text("URL List")
                                                .font(.headline)
                                            Text("The URLs that you want to use with the VPN, separated by spaces")
                                                .font(.caption)
                                            TextEditor(text: $urls)
                                                .frame(minHeight: 150)
                                                .padding()
                                                .cornerRadius(8)
                                                .font(.body)
                                                .background(Color(NSColor.textBackgroundColor))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 5)
                                                        .stroke(.black, lineWidth: 1 / 3)
                                                        .opacity(0.3)
                                                )
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color(NSColor.gridColor)) // Use your desired background color
                            
                        }
                        
                    }
                }
                // end vstack
                .padding()
            }
            // end scrollview
            .frame(alignment: .trailing)
            
            Spacer()
            
            HStack {
                Spacer()
                Button("Cancel") {
                    windowController?.closeWindow()
                }
                
                Button("Done") {
                    UserDefaults.standard.set(tokenPasscode, forKey: "passcode")
                    UserDefaults.standard.set(hostURL, forKey: "hostURL")
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(password, forKey: "password")
                    UserDefaults.standard.set(useSlice, forKey: "useSlice")
                    UserDefaults.standard.set(urls, forKey: "urls")
                    
                    windowController?.closeWindow()
                }
            }
            .padding()
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(width: 300)
        .frame(maxHeight: 400)
    }
}
