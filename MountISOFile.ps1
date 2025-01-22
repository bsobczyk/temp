function Mount-ISOFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Test-Path $_ })]
        [string]$ISOPath
    )

    try {
        # Sprawdź czy plik istnieje i czy jest to plik ISO
        if (-not (Test-Path $ISOPath)) {
            throw "Plik ISO nie istnieje: $ISOPath"
        }

        if ([System.IO.Path]::GetExtension($ISOPath) -ne ".iso") {
            throw "Podany plik nie jest plikiem ISO: $ISOPath"
        }

        # Zamień ścieżkę względną na bezwzględną
        $ISOPath = (Resolve-Path $ISOPath).Path

        # Zamontuj obraz ISO
        Write-Verbose "Montowanie obrazu ISO: $ISOPath"
        $mountResult = Mount-DiskImage -ImagePath $ISOPath -PassThru

        # Pobierz literę dysku
        $driveLetter = ($mountResult | Get-Volume).DriveLetter

        if (-not $driveLetter) {
            throw "Nie udało się uzyskać litery dysku dla zamontowanego obrazu ISO"
        }

        # Zwróć literę dysku
        return "$($driveLetter):"
    }
    catch {
        Write-Error "Wystąpił błąd podczas montowania pliku ISO: $_"
        return $null
    }
}

# Przykład użycia:
# $driveLetter = Mount-ISOFile -ISOPath "C:\Path\To\Your\File.iso"
# if ($driveLetter) {
#     Write-Host "Obraz ISO został zamontowany jako dysk: $driveLetter"
# }
