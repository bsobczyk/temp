param(
    [Parameter(Mandatory=$true)]
    [string]$OvaPath,
    
    [Parameter(Mandatory=$true)]
    [string]$VmName,
    
    [Parameter(Mandatory=$false)]
    [string]$DestinationPath = "$env:USERPROFILE\Documents\Virtual Machines",
    
    [Parameter(Mandatory=$false)]
    [int]$CpuCount = 2,
    
    [Parameter(Mandatory=$false)]
    [int]$MemoryMB = 4096,
    
    [Parameter(Mandatory=$false)]
    [string]$NetworkType = "nat", # Options: nat, bridged, hostonly
    
    [Parameter(Mandatory=$false)]
    [hashtable]$Properties = @{},
    
    [Parameter(Mandatory=$false)]
    [switch]$StartVM = $true
)

# Paths to required tools
$ovftool = "${env:ProgramFiles}\VMware\VMware OVF Tool\ovftool.exe"
$vmrun = "${env:ProgramFiles(x86)}\VMware\VMware Workstation\vmrun.exe"

# Function to validate paths and tools
function Test-Requirements {
    if (-not (Test-Path $ovftool)) {
        throw "OVF Tool not found at: $ovftool"
    }
    if (-not (Test-Path $vmrun)) {
        throw "VMrun not found at: $vmrun"
    }
    if (-not (Test-Path $OvaPath)) {
        throw "OVA file not found at: $OvaPath"
    }
}

# Function to get OVF properties
function Get-OvfProperties {
    $props = & $ovftool --showProperties $OvaPath 2>&1
    $propDict = @{}
    
    foreach ($line in $props) {
        if ($line -match '^(\S+)\s*=\s*(.*)$') {
            $key = $matches[1].Trim()
            $value = $matches[2].Trim()
            $propDict[$key] = $value
        }
    }
    return $propDict
}

# Function to build ovftool arguments
function Get-OvfToolArgs {
    $args = @(
        "--name=`"$VmName`""
        "--numberOfCpus=$CpuCount"
        "--memSize=$MemoryMB"
        "--network=$NetworkType"
    )
    
    # Add properties if specified
    foreach ($prop in $Properties.GetEnumerator()) {
        $args += "--prop:$($prop.Key)=`"$($prop.Value)`""
    }
    
    return $args
}

# Main deployment function
function Deploy-VM {
    try {
        # Create destination folder if it doesn't exist
        $vmPath = Join-Path $DestinationPath $VmName
        if (-not (Test-Path $vmPath)) {
            New-Item -ItemType Directory -Path $vmPath -Force | Out-Null
        }

        # Build ovftool command
        $ovfArgs = Get-OvfToolArgs
        $ovfArgs += "`"$OvaPath`""
        $ovfArgs += "`"$vmPath`""
        
        Write-Host "Deploying VM from OVA..."
        $result = & $ovftool $ovfArgs 2>&1
        
        if ($LASTEXITCODE -ne 0) {
            throw "OVF Tool deployment failed: $result"
        }
        
        # Get path to VMX file
        $vmxPath = Get-ChildItem -Path $vmPath -Filter "*.vmx" -Recurse | Select-Object -First 1 -ExpandProperty FullName
        
        if (-not $vmxPath) {
            throw "VMX file not found after deployment"
        }
        
        # Start VM if requested
        if ($StartVM) {
            Write-Host "Starting VM..."
            & $vmrun start $vmxPath
            
            # Wait for VMware Tools to become available
            Write-Host "Waiting for VMware Tools..."
            do {
                Start-Sleep -Seconds 5
                $toolsStatus = & $vmrun checkToolsState $vmxPath 2>&1
            } while ($toolsStatus -ne "running")
            
            Write-Host "VM is ready and VMware Tools are running"
        }
        
        return @{
            Success = $true
            VmxPath = $vmxPath
            Message = "VM deployment completed successfully"
        }
        
    } catch {
        return @{
            Success = $false
            VmxPath = $null
            Message = "Deployment failed: $_"
        }
    }
}

# Main execution
try {
    # Validate requirements
    Test-Requirements
    
    # Get available properties
    $availableProps = Get-OvfProperties
    Write-Host "Available OVF properties:"
    $availableProps.GetEnumerator() | ForEach-Object {
        Write-Host "  $($_.Key) = $($_.Value)"
    }
    
    # Validate provided properties
    foreach ($prop in $Properties.Keys) {
        if (-not $availableProps.ContainsKey($prop)) {
            Write-Warning "Property '$prop' is not defined in the OVF file"
        }
    }
    
    # Deploy VM
    Write-Host "`nStarting VM deployment..."
    $result = Deploy-VM
    
    if ($result.Success) {
        Write-Host "`nDeployment successful!"
        Write-Host "VMX path: $($result.VmxPath)"
    } else {
        Write-Error $result.Message
        exit 1
    }
    
} catch {
    Write-Error $_
    exit 1
}
