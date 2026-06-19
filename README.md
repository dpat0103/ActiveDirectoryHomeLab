# Active Directory Home Lab

A home lab simulating an enterprise IT environment using Windows Server 2022 and Windows 10. Built to demonstrate hands-on experience with Active Directory, Group Policy, DNS/DHCP, and help desk ticketing workflows.

---

## Tech Stack

- Windows Server 2022 (Domain Controller)
- Windows 10 (Domain-joined client)
- Active Directory Domain Services (AD DS)
- DNS & DHCP
- Group Policy Management (GPO)
- osTicket (Help Desk Ticketing)
- PowerShell (User provisioning automation)
- VirtualBox (Hypervisor)

---

## What I Built

### Domain Controller Setup
- Deployed Windows Server 2022 as a domain controller for the `corp.local` domain
- Configured static IP, DNS, and DHCP roles on the server
- Promoted the server to a DC using AD DS

### Organizational Unit Structure
Designed a hierarchical OU structure to mirror a real corporate environment:
```
corp.local
  └── Corp
        ├── IT
        ├── HR
        └── Finance
```

### User Provisioning
- Created user accounts across OUs manually and via PowerShell automation
- Bulk-imported users from a CSV file using a custom PowerShell script (see `/scripts/bulk-create-users.ps1`)

### Group Policy
- Created and linked a GPO to the Corp OU enforcing a desktop lockdown policy
- Verified GPO enforcement on the domain-joined client by confirming Control Panel access was blocked for standard users

### Domain-Joined Client
- Configured a Windows 10 VM with DNS pointing to the DC
- Successfully joined the machine to `corp.local`
- Logged in as domain users and confirmed GPO policies applied correctly

### Help Desk Ticketing (osTicket)
- Installed and configured osTicket on the server (IIS + PHP + MySQL)
- Created sample tickets simulating real support scenarios:
  - Password reset request
  - VPN access needed
  - Application not launching
- Resolved tickets through the admin panel, simulating a basic help desk workflow

---

## Scripts

### `bulk-create-users.ps1`
Reads a CSV file of users and bulk-creates them in Active Directory, assigning each to the correct OU based on department.

**Usage:**
```powershell
.\bulk-create-users.ps1 -CsvPath ".\users.csv"
```

**CSV format:**
```
FirstName,LastName,Username,Department,Password
John,Smith,jsmith,IT,Welcome1!
Maria,Wilson,mwilson,HR,Welcome1!
Tom,Lee,tlee,Finance,Welcome1!
```

---

## Key Concepts Demonstrated

- Active Directory structure and object management
- GPO creation, linking, and enforcement
- DNS and DHCP configuration in a Windows Server environment
- Domain join process and user authentication
- PowerShell scripting for IT automation
- Help desk ticketing and ticket lifecycle management

---

## Lab Architecture

```
VirtualBox Internal Network (ADLab)
  ├── DC01 — Windows Server 2022
  │     IP: 10.0.2.10 (static)
  │     Roles: AD DS, DNS, DHCP, osTicket
  │
  └── CLIENT01 — Windows 10
        IP: via DHCP
        Joined to: corp.local
```
