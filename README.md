# Kura-Kura

<p align="center">
  <img width="256" alt="kura-kura" src="https://github.com/user-attachments/assets/224310cc-7413-4313-af6a-4b52c8971cc5">
</p>

<p align="center">
  Icon generated with Perchance. 🧐 
</p>


Kura-Kura is a simple VPN GUI for the (semi-)automatic script from my other [repository](https://github.com/idrakimuhamad/open-connect-auto-login-script).

<img width="512" alt="image" src="https://github.com/user-attachments/assets/32ea7937-ef53-45ef-bc31-d57c980a62aa">


It allows you to set the data needed, such as the server address, username, and password, and then connect to the VPN server with a single click. It also provide VPN slice so you can provide list of URLs that will be accessed through the VPN connection.

## Prerequisites

The app requires the following packages to be installed:

- homebrew
- openconnect
- stoken
- vpn-slice

All of this can be installed through Homebrew.

## Installation

As the app are unsigned, you might hit with MacOS gatekeeper if you download the zip directly, and extract it. Few way to get around this is by download it with cURL.

```
curl https://github.com/idrakimuhamad/kura-kura-vpn/releases/download/0.1.1/kura-kura-0.1.1.zip --output ~/Downloads/kura-kura.zip
```

Replace the version with the latest tag.

Another is to just download it from release, and then manually remove the quarantine (if it is).

```
xattr -d com.apple.quarantine ~/Downloads/kura-kura.zip
```

You can then unzip and open the app.
