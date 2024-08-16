import SwiftUI

struct SettingsView: View {
    @Binding var tokenPasscode: String
    @Binding var hostURL: String
    @Binding var username: String
    @Binding var password: String
    @Binding var urls: [String]
    
    @State private var isPasswordVisible: Bool = false
    @State private var isFocusedOnUrl: Bool = false
    @FocusState private var isTextFieldFocused: Bool
    @State private var isAddingUrl: Bool = false
    @State private var tempUrl: String = ""
    @State private var selectedUrlIndex: Int = -1
    
    var windowController: SettingsWindowController?
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack (spacing: 4) {
                    Image("kura")
                        .resizable()
                        .frame(width: 128, height: 128)
                    
                    HStack {
                        Text("Version:")
                        Text("0.1.1")
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        InfoRow(value: $hostURL, title: "VPN Host URL", divider: true)
                        InfoRow(value: $username, title: "User", caption: "The username or ID use to login to the network", divider: true)
                        InfoRow(value: $password, title: "Password", caption: "The password use to login to company portal's or VPN", divider: true, secure: true)
                        InfoRow(value: $tokenPasscode, title: "Passcode", caption: "The passcode use to lock the OTP when setting up the stoken", secure: true)
                        
                    }
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.separator, lineWidth: 1)
                    )
                }
                .padding()
                
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("URL Address for VPN Slice")
                            .font(.headline)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        VStack(alignment: .leading, spacing: 0) {
                            if urls.isEmpty && !isAddingUrl {
                                Text("URL Address")
                                    .foregroundColor(.secondary)
                                    .padding(4)
                                    .padding(.leading, 8)
                                    .padding(.trailing, 8)
                            } else {
                                ForEach(urls.indices, id: \.self) { index in
                                    VStack(alignment: .leading, spacing: 0) {
                                        if selectedUrlIndex == index {
                                            TextField("", text: $tempUrl)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .focused($isTextFieldFocused)
                                                .onAppear {
                                                    // Set the initial focus when the view appears
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                                        self.isTextFieldFocused = true
                                                    }
                                                }
                                        } else {
                                            HStack {
                                                Text(urls[index])
                                                    .foregroundColor(.primary)
                                                    .padding(4)
                                                    .padding(.leading, 8)
                                                    .padding(.trailing, 8)
                                                
                                                Spacer() // This makes the entire row tappable
                                            }
                                            .contentShape(Rectangle()) // Defines the tappable area
                                            
                                        }
                                        
                                        if index != urls.indices.last {
                                            Divider()
                                        }
                                    }
                                    .onTapGesture {
                                        // Handle row click
                                        selectedUrlIndex = index
                                        
                                        tempUrl = urls[index] // Auto-fill the text field with the selected URL
                                        
                                        // Set focus to the text field
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            self.isTextFieldFocused = true
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    
                                }
                            }
                            
                            if isAddingUrl {
                                TextField("", text: $tempUrl)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .focused($isTextFieldFocused)
                                    .onAppear {
                                        // Set the initial focus when the view appears
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                            self.isTextFieldFocused = true
                                        }
                                    }
                                    .padding(4)
                            }
                        }
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .leading)
                        .background(.background.opacity(0.5))
                        
                        HStack {
                            Button(action: {
                                addUrl()
                            }) {
                                Image(systemName: "plus")
                                    .foregroundColor(.primary)
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Divider()
                            
                            Button(action: {
                                removeSelectedUrl()
                            }) {
                                Image(systemName: "minus")
                                    .foregroundColor(.primary)
                                
                                
                            }
                            .buttonStyle(PlainButtonStyle())
                            .disabled(selectedUrlIndex == -1)
                        }
                        .padding(8)
                    }
                    .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                    .cornerRadius(4)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(.separator, lineWidth: 1)
                    )
                }
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
                    UserDefaults.standard.set(urls, forKey: "urls")
                    
                    windowController?.closeWindow()
                }
                .buttonStyle(BorderedProminentButtonStyle())
            }
            .padding()
            .background(Color(.secondarySystemFill))
        }
        .background(Color(NSColor.windowBackgroundColor))
        .frame(width: 500)
        .frame(maxHeight: 400)
        .onTapGesture {
            // adding new item
            if isAddingUrl {
                isTextFieldFocused = false
                isAddingUrl = false
                
                if !tempUrl.isEmpty {
                    urls.append(tempUrl)
                    tempUrl = ""
                }
            }
            
            // updating existing item
            if selectedUrlIndex > -1 {
                
                isTextFieldFocused = false
                
                // if its not empty, replace the value
                // if its empty it should return back to normal
                if !tempUrl.isEmpty {
                    urls[selectedUrlIndex] = tempUrl
                    tempUrl = ""
                }
                
                selectedUrlIndex = -1
            }
        }
    }
    
    func addUrl() {
        isAddingUrl = true
    }
    
    func removeSelectedUrl() {
        if selectedUrlIndex > -1 {
            // remove it from the sets
            urls.remove(at: selectedUrlIndex)
            
            selectedUrlIndex = -1
            isTextFieldFocused = false
            tempUrl = ""
        }
    }
}

struct InfoRow: View {
    @Binding var value: String
    var title: String
    var caption: String = ""
    var divider: Bool = false
    var secure: Bool = false
    @State private var isSecureVisible: Bool = true
    
    var body: some View {
        HStack {
            VStack(spacing: 0) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(title)
                            .font(
                                .system(size: 13)
                            )
                            .foregroundColor(.primary)
                        
                        if !caption.isEmpty {
                            Text(caption)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    if (secure && isSecureVisible) {
                        SecureField("", text: $value)
                            .textFieldStyle(PlainTextFieldStyle())
                            .background(Color(NSColor.gridColor))
                            .frame(width: 200)
                            .multilineTextAlignment(.trailing)
                    } else {
                        TextField("", text: $value)
                            .textFieldStyle(PlainTextFieldStyle())
                            .background(Color(NSColor.gridColor))
                            .frame(width: 200)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if (secure) {
                        Button(action: {
                            isSecureVisible.toggle()
                        }) {
                            Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                                .padding(4)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(8)
                
                if divider {
                    VStack {
                        Divider()
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
        .background(Color(NSColor.gridColor))
    }
}
