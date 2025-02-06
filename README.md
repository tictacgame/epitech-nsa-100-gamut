# EPITECH PROJECT, 2025

## GAMUT Installation Guide

This README provides a step-by-step guide for setting up the **GAMUT** project as part of the **G1-Networks-And-System-Administration** unit.

---

### **Minimal System Requirements**
- **RAM:** 2 GB  
- **Processor:** 1 Core  
- **Disk Space:** 61 GB (120 GB recommended)  
- **Internet Connection:** Required  

---

### **Installation Command**
Run the following command to begin the installation:  
```bash
curl https://raw.githubusercontent.com/tictacgame/install-gamut/refs/heads/master/arch-x-parrot.sh -o install.sh && chmod +x install.sh && ./install.sh
```

---

### **Installation Script Details**

The installation script performs the following tasks:

1. **Keyboard Configuration:** Sets the keyboard layout to French (`fr`).  
2. **System Update:** Updates the package mirrors using `pacman`.  
3. **Disk Partitioning:** Creates and formats partitions for EFI, LVM, and additional spaces for dual boot with ParrotOS.  
    - **Partitions for ParrotOS:**  
      - `/dev/sda3`, `/dev/sda4`, `/dev/sda5`, `/dev/sda6` are dedicated for the dual-boot configuration with **ParrotOS**.
    - **Partitions for GAMUT (Arch Linux):**  
      - Creates partitions for EFI, LVM, and logical volumes for `swap`, `boot`, `root`, and `home`.  
4. **Logical Volume Management (LVM):** Configures LVM with separate logical volumes for `swap`, `boot`, `root`, and `home`.  
5. **File System Formatting:** Formats the partitions with `ext4`, `ext2`, and swap.  
6. **Base System Installation:** Installs essential packages (`base`, `linux`, `lvm2`, `networkmanager`, etc.).  
7. **System Configuration:**
   - Timezone (`Europe/Paris`) and localization (`en_US.UTF-8`) setup.  
   - Hostname and network settings configuration.  
   - Enables LVM in `mkinitcpio`.  
8. **User Setup:**  
   - Creates an `admin` user with `wheel` privileges.  
   - Configures root and admin user passwords.  
9. **Service Activation:** Enables `NetworkManager` for networking.  

---

### **Important Notes**
- **Dual Boot Configuration:**
- Ensure your system meets the **minimum requirements** before proceeding.  
- The script assumes the use of **`/dev/sda`** for disk configuration. Modify accordingly if your setup differs.  
- Make sure to execute this command on the Arch Linux installer.

---

### **Post-Installation**
After the script completes:

1. **Reboot the system:**  
   ```bash
   reboot
   ```

2. **Login:** Use the credentials created during the setup (`root` or `admin`).  

3. **Check Network Connection:** Ensure `NetworkManager` is running:  
   ```bash
   systemctl status NetworkManager
   ```

4. **Verify Disk Partitions:** Use `lsblk` or `df -h` to check mounted partitions.

5. **Install ParrotOS:** You must install ParrotOS yourself, as it requires a graphical installation. You can use the partitions `/dev/sda3` to `/dev/sda6` for this installation.

5. **Boot Menu:** Upon reboot, the system should provide an option to select between **GAMUT (Linux)** and **ParrotOS**.

---

### **Contributors**
- **Student:** Kevin  
- **Repository:** [TicTacGame Installation Scripts](https://github.com/tictacgame/install-gamut)
