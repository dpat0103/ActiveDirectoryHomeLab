# bulk-create-users.ps1
# Bulk-creates Active Directory users from a CSV file
# Assigns each user to the correct OU based on their Department column
#
# Usage: .\bulk-create-users.ps1 -CsvPath ".\users.csv"
#
# Required CSV columns: FirstName, LastName, Username, Department, Password
#
# CSV example:
#   FirstName,LastName,Username,Department,Password
#   John,Smith,jsmith,IT,Welcome1!
#   Maria,Wilson,mwilson,HR,Welcome1!
#   Tom,Lee,tlee,Finance,Welcome1!

param (
    [Parameter(Mandatory = $true)]
    [string]$CsvPath
)

# --- Configuration ---
$Domain     = "DC=corp,DC=local"
$BaseOU     = "OU=Corp,$Domain"

# Map department names to their OU paths
$OUMap = @{
    "IT"      = "OU=IT,$BaseOU"
    "HR"      = "OU=HR,$BaseOU"
    "Finance" = "OU=Finance,$BaseOU"
}

# --- Import Active Directory module ---
Import-Module ActiveDirectory -ErrorAction Stop

# --- Validate CSV path ---
if (-not (Test-Path $CsvPath)) {
    Write-Error "CSV file not found at path: $CsvPath"
    exit 1
}

# --- Import CSV ---
$Users = Import-Csv -Path $CsvPath
Write-Host "`nImported $($Users.Count) user(s) from $CsvPath`n" -ForegroundColor Cyan

$Created = 0
$Skipped = 0
$Failed  = 0

foreach ($User in $Users) {

    $FirstName   = $User.FirstName.Trim()
    $LastName    = $User.LastName.Trim()
    $Username    = $User.Username.Trim()
    $Department  = $User.Department.Trim()
    $Password    = $User.Password.Trim()
    $DisplayName = "$FirstName $LastName"
    $UPN         = "$Username@corp.local"

    # Validate department has a mapped OU
    if (-not $OUMap.ContainsKey($Department)) {
        Write-Warning "[$Username] Unknown department '$Department' — skipping."
        $Skipped++
        continue
    }

    $TargetOU = $OUMap[$Department]

    # Check if user already exists
    if (Get-ADUser -Filter { SamAccountName -eq $Username } -ErrorAction SilentlyContinue) {
        Write-Warning "[$Username] Already exists in AD — skipping."
        $Skipped++
        continue
    }

    # Create the user
    try {
        New-ADUser `
            -SamAccountName       $Username `
            -UserPrincipalName    $UPN `
            -Name                 $DisplayName `
            -GivenName            $FirstName `
            -Surname              $LastName `
            -DisplayName          $DisplayName `
            -Department           $Department `
            -Path                 $TargetOU `
            -AccountPassword      (ConvertTo-SecureString $Password -AsPlainText -Force) `
            -Enabled              $true `
            -PasswordNeverExpires $true `
            -ErrorAction Stop

        Write-Host "[OK] Created: $DisplayName ($Username) → $Department" -ForegroundColor Green
        $Created++
    }
    catch {
        Write-Host "[FAIL] Could not create $Username — $($_.Exception.Message)" -ForegroundColor Red
        $Failed++
    }
}

# --- Summary ---
Write-Host "`n--- Summary ---" -ForegroundColor Cyan
Write-Host "Created : $Created" -ForegroundColor Green
Write-Host "Skipped : $Skipped" -ForegroundColor Yellow
Write-Host "Failed  : $Failed"  -ForegroundColor Red
Write-Host ""
