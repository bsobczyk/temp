param(
    [Parameter(Mandatory=$true)]
    [string]$IPAddress,
    
    [Parameter(Mandatory=$true)]
    [string]$Hostname,
    
    [Parameter(Mandatory=$false)]
    [string]$HostsFilePath = "$env:SystemRoot\System32\drivers\etc\hosts"
)

# Ensure running as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "This script requires administrator privileges. Please run as administrator."
    exit 1
}

try {
    # Validate IP address format
    $ipRegex = "^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$"
    if (-not ($IPAddress -match $ipRegex)) {
        Write-Error "Invalid IP address format: $IPAddress"
        exit 1
    }

    # Check if hosts file exists
    if (-not (Test-Path $HostsFilePath)) {
        Write-Error "Hosts file not found at: $HostsFilePath"
        exit 1
    }

    # Read current content
    $hostsContent = @(Get-Content $HostsFilePath -Raw)

    # Check if entry already exists
    $existingLines = $hostsContent -split "`r`n"
    $entryExists = $existingLines | Where-Object { 
        $_ -match "^\s*$IPAddress\s+$Hostname\s*$" -or 
        $_ -match "^\s*[0-9.]+\s+$Hostname\s*$"
    }

    if ($entryExists) {
        Write-Warning "An entry for hostname '$Hostname' already exists in the hosts file."
        Write-Output "Existing entry: $entryExists"
        $confirm = Read-Host "Do you want to update it? (Y/N)"
        if ($confirm -ne "Y") {
            Write-Output "Operation cancelled."
            exit 0
        }
        # Remove existing entry
        $existingLines = $existingLines | Where-Object { 
            $_ -notmatch "^\s*[0-9.]+\s+$Hostname\s*$"
        }
    }

    # Backup original file
    $backupPath = "$HostsFilePath.bak"
    Copy-Item $HostsFilePath $backupPath -Force
    Write-Output "Backup created at: $backupPath"

    # Add new entry and prepare content
    $newEntry = "$IPAddress`t$Hostname"
    if ($existingLines[-1] -ne "") {
        $newEntry = "`r`n$newEntry"
    }
    $existingLines += $newEntry

    # Write updated content using Out-File
    $existingLines | Out-File -FilePath $HostsFilePath -Encoding ASCII -Force
    Write-Output "Successfully added entry: $IPAddress -> $Hostname"
    Write-Output "Hosts file updated at: $HostsFilePath"

} catch {
    Write-Error "An error occurred: $_"
    exit 1
}
