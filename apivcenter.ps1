function Get-VCenterAPIToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$VCenterServer,
        
        [Parameter(Mandatory = $true)]
        [string]$Username,
        
        [Parameter(Mandatory = $true)]
        [SecureString]$Password
    )
    
    try {
        # Ignorowanie błędów certyfikatu SSL
        if (-not ([System.Management.Automation.PSTypeName]'TrustAllCertsPolicy').Type) {
            Add-Type @"
                using System.Net;
                using System.Security.Cryptography.X509Certificates;
                public class TrustAllCertsPolicy : ICertificatePolicy {
                    public bool CheckValidationResult(
                        ServicePoint srvPoint, X509Certificate certificate,
                        WebRequest request, int certificateProblem) {
                        return true;
                    }
                }
"@
        }
        [System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        
        # Konwersja SecureString na plain text dla potrzeb API
        $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password)
        $PlainPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
        
        # Przygotowanie body żądania
        $Body = @{
            username = $Username
            password = $PlainPassword
        } | ConvertTo-Json
        
        # Przygotowanie URL
        $URI = "https://$VCenterServer/rest/com/vmware/cis/session"
        
        # Wywołanie API
        $Response = Invoke-RestMethod -Uri $URI -Method Post -Body $Body -ContentType 'application/json' -ErrorAction Stop
        
        # Zwrócenie tokenu
        return $Response.value
        
    }
    catch {
        Write-Error "Błąd podczas generowania tokenu API: $_"
        return $null
    }
    finally {
        if ($BSTR) {
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
        }
    }
}

# Przykład użycia:
# $vcServer = "vcenter.example.com"
# $vcUsername = "administrator@vsphere.local"
# $vcPassword = Read-Host -AsSecureString "Podaj hasło"
# $token = Get-VCenterAPIToken -VCenterServer $vcServer -Username $vcUsername -Password $vcPassword
