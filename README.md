# wifiCrack.sh

`wifiCrack.sh` is a Bash script designed for performing penetration testing on WiFi networks. It allows capturing handshakes and executing PMKID attacks to evaluate the security of wireless networks.

This script is based on the tool created by the Spanish hacker Marcelo 'S4vitar' Vázquez, who demonstrated its usage in a live stream on Twitch, which was later uploaded to YouTube.

Watch the video here: [Marcelo 'S4vitar' Vázquez - WiFi Cracking Live Stream](https://www.youtube.com/watch?v=Mwt_RbdpJhk&t=3768s)

**Disclaimer**: This tool should only be used for educational purposes and on networks you own or have explicit permission to test. Unauthorized access to networks is illegal.
---

> [!IMPORTANT]  
> This script is specifically designed for **Arch Linux** and its derivatives. If you are using another distribution, you may need to manually install the dependencies or adapt the script to your package manager.

> [!WARNING]  
> Running this script without proper authorization is **illegal** and **unethical**. Ensure you have explicit permission to test the target network.

---

## Key Features

- **Handshake Capture**: Captures WiFi handshakes for further analysis and cracking.
- **PMKID Attack**: Performs a PKMID attack to obtain the PMKID hash from an access point.
- **User-Friendly Interface**: Uses colors and clear messages to guide the user through the process.
- **Dependency Check**: Automatically checks and installs required tools.
- **Monitor Mode**: Configures the network card in monitor mode for attacks.

---

### Requirements
- **paru**: A package manager for Arch Linux and its derivatives. The script uses `paru` to install missing dependencies.
- **bspwm (optional)**: If you are using the `bspwm` window manager, it is recommended to add the following rule to your `bspwmrc` file to ensure `XTerm` windows open in floating mode:
  ```bash
  bspc rule -a XTerm state=floating 

---

## Parameters

- `-a`: Specifies the attack mode. Possible values are:
  - **Handshake**: Captures a WiFi handshake.
  - **PKMID**: Performs a PKMID attack to obtain the PMKID hash.
- `-n`: Name of the wireless network card (e.g., `wlan0`).
- `-h`: Displays the help panel.

---

## Usage Examples

### Capture a Handshake:
```bash
sudo ./wifiCrack.sh -a Handshake -n wlan0
```

### Perform a PKMID Attack:
```bash
sudo ./wifiCrack.sh -a PKMID -n wlan0
```

## Detailed Instructions

### Preparation
- Ensure you have a network card compatible with monitor mode.
- Run the script with superuser privileges (`sudo`).

### Select Attack Mode
- Choose between **Handshake** or **PKMID**.

### Network Card Configuration
- The script will automatically configure the network card in monitor mode.

### Execute the Attack
- Follow the on-screen instructions to provide ESSID and channel.
- The script will capture the handshake or PMKID hash.

### Password Cracking
- Uses aircrack-ng or hashcat for password cracking.

> 💡 **NOTE**  
> The Handshake attack requires the target network to have active clients. If no clients are connected, the attack may fail.

---

## Ethical Considerations

This script is intended solely for educational purposes and security testing on networks you own or have explicit permission to test.

> ⚠ **WARNING**  
> Always obtain written permission before testing any network. Unauthorized access is a criminal offense in most jurisdictions.

---

## License

This project is licensed under the [MIT License](https://github.com/Unfiw/wifiCrack/blob/main/LICENSE).

