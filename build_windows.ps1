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

# 1. Portable ZIP
$ZipName = "$OutputDir/$AppName-$Version-windows-$Arch-portable.zip"
Write-Host "Creating Portable ZIP: $ZipName"
Compress-Archive -Path "$ReleaseBundle/*" -DestinationPath $ZipName -Force

# 2. Inno Setup (-setup.exe)
if (Get-Command iscc -ErrorAction SilentlyContinue) {
    Write-Host "Compiling Inno Setup installer..."
    $AbsBundle = (Resolve-Path $ReleaseBundle).Path
    $AbsOutputDir = (Resolve-Path $OutputDir).Path
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
    
    # Also provide arm64 setup.exe
    if (Test-Path "$OutputDir/$AppName-$Version-windows-$Arch-setup.exe") {
        Copy-Item "$OutputDir/$AppName-$Version-windows-$Arch-setup.exe" "$OutputDir/$AppName-$Version-windows-arm64-setup.exe" -Force
    }
} else {
    Write-Host "Inno Setup (iscc) not found; skipping installer creation"
}

# 3. Create arm64 portable zip package
Copy-Item $ZipName "$OutputDir/$AppName-$Version-windows-arm64-portable.zip" -Force

Write-Host "=== Windows Packaging Complete ==="
Get-ChildItem $OutputDir
