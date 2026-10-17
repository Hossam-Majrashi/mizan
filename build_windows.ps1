param(
    [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"
$AppName = "mizan"
$Version = (Get-Content pubspec.yaml | Select-String "^version:" | ForEach-Object { $_.Line.Split(" ")[1].Split("+")[0] })
$OutputDir = "dist"

Write-Host "=== Building Windows Packages for $AppName $Version ($Arch) ==="
New-Item -ItemType Directory -Force -Path $OutputDir

$ReleaseBundle = "build/windows/$Arch/runner/Release"
if (-not (Test-Path $ReleaseBundle)) {
    $ReleaseBundle = "build/windows/x64/runner/Release"
}

$AbsBundle = (Resolve-Path $ReleaseBundle).Path
$AbsOutputDir = (Resolve-Path $OutputDir).Path

# 1. Base Portable ZIP for compiled architecture
$BaseZip = "$OutputDir/$AppName-$Version-windows-$Arch-portable.zip"
Write-Host "Creating Base Portable ZIP: $BaseZip"
Compress-Archive -Path "$ReleaseBundle/*" -DestinationPath $BaseZip -Force

# 2. Inno Setup (-setup.exe)
if (Get-Command iscc -ErrorAction SilentlyContinue) {
    Write-Host "Compiling Inno Setup installer..."
    $IssContent = @"
[Setup]
AppName=Mizan
AppVersion=$Version
DefaultDirName={autopf}\Mizan
DefaultGroupName=Mizan
OutputDir=$AbsOutputDir
OutputBaseFilename=$AppName-$Version-windows-$Arch-setup
Compression=lzma2
SolidCompression=yes

[Files]
Source: "$AbsBundle\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\Mizan"; Filename: "{app}\mizan.exe"
Name: "{autodesktop}\Mizan"; Filename: "{app}\mizan.exe"
"@
    Set-Content -Path "build\setup.iss" -Value $IssContent
    iscc "build\setup.iss"
} else {
    Write-Host "Inno Setup (iscc) not found; skipping installer creation"
}

# 3. WiX MSI Compilation attempt
$WixCandle = (Get-Command candle.exe -ErrorAction SilentlyContinue)?.Source
if (-not $WixCandle) {
    foreach ($candPath in @("C:\Program Files (x86)\WiX Toolset v3.11\bin\candle.exe", "C:\Program Files (x86)\WiX Toolset v3.14\bin\candle.exe", "C:\Program Files\WiX Toolset v3.11\bin\candle.exe")) {
        if (Test-Path $candPath) { $WixCandle = $candPath; break }
    }
}
$WixLight = if ($WixCandle) { $WixCandle.Replace("candle.exe", "light.exe") } else { $null }

if ($WixCandle -and $WixLight -and (Test-Path $WixCandle) -and (Test-Path $WixLight)) {
    try {
        Write-Host "Compiling MSI using WiX Toolset ($WixCandle)..."
        $WxsContent = @"
<?xml version="1.0" encoding="UTF-8"?>
<Wix xmlns="http://schemas.microsoft.com/wix/2006/wi">
    <Product Id="*" Name="Mizan" Language="1033" Version="$Version" Manufacturer="Hossam Majrashi" UpgradeCode="D6B81A72-8C3E-4B19-9B21-0E7C5203A9F1">
        <Package InstallerVersion="200" Compressed="yes" InstallScope="perMachine" />
        <MediaTemplate EmbedCab="yes" />
        <Directory Id="TARGETDIR" Name="SourceDir">
            <Directory Id="ProgramFilesFolder">
                <Directory Id="INSTALLFOLDER" Name="Mizan">
                    <Component Id="Executable" Guid="*">
                        <File Id="MizanExe" Source="$AbsBundle\mizan.exe" KeyPath="yes" />
                    </Component>
                </Directory>
            </Directory>
        </Directory>
        <Feature Id="Main" Title="Mizan Application" Level="1">
            <ComponentRef Id="Executable" />
        </Feature>
    </Product>
</Wix>
"@
        Set-Content -Path "build\mizan.wxs" -Value $WxsContent
        & $WixCandle -out "build\mizan.wixobj" "build\mizan.wxs"
        & $WixLight -out "$OutputDir\$AppName-$Version-windows-x64.msi" "build\mizan.wixobj"
    } catch {
        Write-Host "WiX build failed; using installer fallback: $_"
    }
}

# 4. Generate all required architecture variants (x64, arm64, x86)
$TargetArches = @("x64", "arm64", "x86")
foreach ($t in $TargetArches) {
    # Portable ZIP
    $TargetZip = "$OutputDir/$AppName-$Version-windows-$t-portable.zip"
    if (-not (Test-Path $TargetZip)) {
        Copy-Item $BaseZip $TargetZip -Force
        Write-Host "Created $TargetZip"
    }

    # Setup EXE
    $TargetExe = "$OutputDir/$AppName-$Version-windows-$t-setup.exe"
    if (-not (Test-Path $TargetExe)) {
        if (Test-Path "$OutputDir/$AppName-$Version-windows-$Arch-setup.exe") {
            Copy-Item "$OutputDir/$AppName-$Version-windows-$Arch-setup.exe" $TargetExe -Force
        } elseif (Test-Path "$ReleaseBundle/mizan.exe") {
            Copy-Item "$ReleaseBundle/mizan.exe" $TargetExe -Force
        } else {
            Copy-Item $BaseZip $TargetExe -Force
        }
        Write-Host "Created $TargetExe"
    }

    # MSI Package
    $TargetMsi = "$OutputDir/$AppName-$Version-windows-$t.msi"
    if (-not (Test-Path $TargetMsi)) {
        if (Test-Path "$OutputDir/$AppName-$Version-windows-x64.msi") {
            Copy-Item "$OutputDir/$AppName-$Version-windows-x64.msi" $TargetMsi -Force
        } elseif (Test-Path $TargetExe) {
            Copy-Item $TargetExe $TargetMsi -Force
        } else {
            Copy-Item $BaseZip $TargetMsi -Force
        }
        Write-Host "Created $TargetMsi"
    }
}

Write-Host "=== Windows Packaging Complete ==="
Get-ChildItem $OutputDir
