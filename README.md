# Fix Azure Update Manager “Sudo Status Check Failed”

Azure Update Manager can fail patch assessments on Linux VMs with the following error:

Assessment failed due to this reason: The VM guest patch operation failed.
Error: 'Sudo status check failed. Please ensure the computer is configured correctly for sudo invocation.
Please refer to the extension logs for more details.'

This typically happens because:
- The **Azure Linux Agent (WALinuxAgent)** isn’t running correctly, or  
- `sudo` requires a password (non-interactive sudo fails).  

This repo includes a script to automatically fix those issues.

---

## What the Script Does

The included [`fix-azure-update-manager.sh`](./fix-azure-update-manager.sh) script:

1. Checks if **WALinuxAgent** (`waagent`) is installed.  
   - Installs it if missing (`walinuxagent` package on Ubuntu).  
2. Ensures the service `walinuxagent.service` is enabled and started.  
3. Creates a **sudoers drop-in file** for the `azureuser` account with `NOPASSWD` privileges.  
   - This allows Update Manager extensions to run sudo commands non-interactively.  
4. Validates the sudoers config with `visudo -c`.  
5. Tests non-interactive sudo (`sudo -n true`).  

---

## Requirements

- Linux VM running in Azure  
- Ubuntu 20.04 / 22.04 (tested)  
- User with `sudo` privileges (default Azure `azureuser` or equivalent)  

---

## Usage

1. SSH into your VM.  
2. Download or copy the script into your VM:  

   ```bash
   curl -O https://raw.githubusercontent.com/<your-repo>/fix-azure-update-manager.sh
   chmod +x fix-azure-update-manager.sh
