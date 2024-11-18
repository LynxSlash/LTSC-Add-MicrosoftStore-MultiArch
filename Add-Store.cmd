@echo off
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 16299 goto :version
%windir%\system32\reg.exe query "HKU\S-1-5-19" 1>nul 2>nul || goto :uac
setlocal enableextensions
if /i "%PROCESSOR_ARCHITECTURE%" equ "AMD64" (set "arch=x64") else if /i "%PROCESSOR_ARCHITECTURE%" equ "ARM64" (set "arch=arm64") else (set "arch=x86")
cd /d "%~dp0"

if not exist "*WindowsStore*.msixbundle" goto :nofiles
if not exist "*WindowsStore*.xml" goto :nofiles

:: Check if DesktopAppInstaller MSIX bundle exists and download if missing
if not exist "*DesktopAppInstaller*.msixbundle" (
    echo Desktop App Installer msixbundle not found. Downloading now...
    powershell -Command "$spinner = '/|\-'; $i = 0; $filename = ''; $webRequestTask = Start-Job -ScriptBlock { $ProgressPreference = 'SilentlyContinue'; $ProgressPreference = 'SilentlyContinue'; $response = Invoke-WebRequest -Uri 'https://aka.ms/getwinget'; if ($response.Headers['Content-Disposition'] -match 'filename=''(.+?)''') {$filename = $matches[1]} else {$filename = 'Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'}; [System.IO.File]::WriteAllBytes($filename, $response.Content) }; while ($webRequestTask.State -eq 'Running') { Clear-Host; Write-Host ('Downloading... ' + $spinner[$i]); $i = ($i + 1) %% 4; Start-Sleep -Milliseconds 200 }; $response = Receive-Job -Job $webRequestTask; Remove-Job -Job $webRequestTask

    if %errorlevel% neq 0 (
        echo Error downloading Desktop App Installer. Please check your internet connection and try again.
        exit /b 1
    )
    echo Download complete.
)


for /f %%i in ('dir /b *WindowsStore*.msixbundle 2^>nul') do set "Store=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*.appx 2^>nul ^| find /i "x64"') do set "Framework6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*.appx 2^>nul ^| find /i "x86"') do set "Framework6X86=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*.appx 2^>nul ^| find /i "arm64"') do set "Framework6Arm64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*.appx 2^>nul ^| find /i "x64"') do set "Runtime6X64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*.appx 2^>nul ^| find /i "x86"') do set "Runtime6X86=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*.appx 2^>nul ^| find /i "arm64"') do set "Runtime6Arm64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00_14*.appx 2^>nul ^| find /i "x64"') do set "VCLibsX64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00_14*.appx 2^>nul ^| find /i "x86"') do set "VCLibsX86=%%i"
for /f %%i in ('dir /b *VCLibs*140.00_14*.appx 2^>nul ^| find /i "arm64"') do set "VCLibsArm64=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.8*.appx 2^>nul ^| find /i "x64"') do set "Xaml28X64=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.8*.appx 2^>nul ^| find /i "x86"') do set "Xaml28X86=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.8*.appx 2^>nul ^| find /i "arm64"') do set "Xaml28Arm64=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.4*.appx 2^>nul ^| find /i "x64"') do set "Xaml24X64=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.4*.appx 2^>nul ^| find /i "x86"') do set "Xaml24X86=%%i"
for /f %%i in ('dir /b *Microsoft.UI.Xaml.2.4*.appx 2^>nul ^| find /i "arm64"') do set "Xaml24Arm64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00.UWPDesktop*.appx 2^>nul ^| find /i "x64"') do set "VCLibsUWPX64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00.UWPDesktop*.appx 2^>nul ^| find /i "x86"') do set "VCLibsUWPX86=%%i"
for /f %%i in ('dir /b *VCLibs*140.00.UWPDesktop*.appx 2^>nul ^| find /i "arm64"') do set "VCLibsUWPArm64=%%i"

if exist "*StorePurchaseApp*.appxbundle" if exist "*StorePurchaseApp*.xml" (
for /f %%i in ('dir /b *StorePurchaseApp*.appxbundle 2^>nul') do set "PurchaseApp=%%i"
)
if exist "*DesktopAppInstaller*.msixbundle" if exist "*DesktopAppInstaller*.xml" (
for /f %%i in ('dir /b *DesktopAppInstaller*.msixbundle 2^>nul') do set "AppInstaller=%%i"
)
if exist "*XboxIdentityProvider*.appxbundle" if exist "*XboxIdentityProvider*.xml" (
for /f %%i in ('dir /b *XboxIdentityProvider*.appxbundle 2^>nul') do set "XboxIdentity=%%i"
)

if exist "*Microsoft.WindowsTerminal*.msixbundle" if exist "*Microsoft.WindowsTerminal*.xml" (
for /f %%i in ('dir /b *Microsoft.WindowsTerminal*.msixbundle 2^>nul') do set "WindowsTerminal=%%i"
)

if /i %arch%==x64 (
    set "DepStore=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%Xaml24X64%,%Xaml24X86%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPX64%,%VCLibsUWPX86%"
    set "DepPurchase=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPX64%,%VCLibsUWPX86%"
    set "DepXbox=%VCLibsX64%,%VCLibsX86%,%Framework6X64%,%Framework6X86%,%Runtime6X64%,%Runtime6X86%"
    set "DepInstaller=%VCLibsX64%,%VCLibsX86%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPX64%,%VCLibsUWPX86%"
) else (
    if /i %arch%==arm64 (
        set "DepStore=%VCLibsArm64%,%VCLibsX64%,%VCLibsX86%,%Framework6Arm64%,%Framework6X64%,%Framework6X86%,%Runtime6Arm64%,%Runtime6X64%,%Runtime6X86%,%Xaml24arm64%,%Xaml24X64%,%Xaml24X86%,%Xaml28arm64%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPArm64%,%VCLibsUWPX64%,%VCLibsUWPX86%"
        set "DepPurchase=%VCLibsArm64%,%VCLibsX64%,%VCLibsX86%,%Framework6Arm64%,%Framework6X64%,%Framework6X86%,%Runtime6Arm64%,%Runtime6X64%,%Runtime6X86%,%Xaml28arm64%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPArm64%,%VCLibsUWPX64%,%VCLibsUWPX86%"
        set "DepXbox=%VCLibsArm64%,%VCLibsX64%,%VCLibsX86%,%Framework6Arm64%,%Framework6X64%,%Framework6X86%,%Runtime6Arm64%,%Runtime6X64%,%Runtime6X86%"
        set "DepInstaller=%VCLibsArm64%,%VCLibsX64%,%VCLibsX86%,%Xaml28arm64%,%Xaml28X64%,%Xaml28X86%,%VCLibsUWPArm64%,%VCLibsUWPX64%,%VCLibsUWPX86%"
    ) else (
        set "DepStore=%VCLibsX86%,%Framework6X86%,%Runtime6X86%,%Xaml24X86%,%Xaml28X86%,%VCLibsUWPX86%"
        set "DepPurchase=%VCLibsX86%,%Framework6X86%,%Runtime6X86%,%Xaml28X86%,%VCLibsUWPX86%"
        set "DepXbox=%VCLibsX86%,%Framework6X86%,%Runtime6X86%"
        set "DepInstaller=%VCLibsX86%,%Xaml28X86%,%VCLibsUWPX86%"
    )
)

for %%i in (%DepStore%) do (
if not exist "%%i" goto :nofiles
)

set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass"

echo.
echo ============================================================
echo Adding Microsoft Store
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Store% -DependencyPackagePath %DepStore% -LicensePath Microsoft.WindowsStore_8wekyb3d8bbwe.xml
for %%i in (%DepStore%) do (
%PScommand% Add-AppxPackage -Path %%i
)
%PScommand% Add-AppxPackage -Path %Store%

if defined PurchaseApp (
echo.
echo ============================================================
echo Adding Store Purchase App
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %PurchaseApp% -DependencyPackagePath %DepPurchase% -LicensePath Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %PurchaseApp%
)
if defined AppInstaller (
echo.
echo ============================================================
echo Adding App Installer
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %AppInstaller% -DependencyPackagePath %DepInstaller% -LicensePath Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %AppInstaller%
)
if defined XboxIdentity (
echo.
echo ============================================================
echo Adding Xbox Identity Provider
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %XboxIdentity% -DependencyPackagePath %DepXbox% -LicensePath Microsoft.XboxIdentityProvider_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %XboxIdentity%
)
if defined WindowsTerminal (
echo.
echo ============================================================
echo Adding WindowsTerminal
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %WindowsTerminal% -DependencyPackagePath %DepInstaller% -LicensePath Microsoft.WindowsTerminal_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %WindowsTerminal%
)


goto :fin

:uac
echo.
echo ============================================================
echo Error: Run the script as administrator
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:version
echo.
echo ============================================================
echo Error: This pack is for Windows 10 version 1709 and later
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:nofiles
echo.
echo ============================================================
echo Error: Required files are missing in the current directory
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:fin
echo.
echo ============================================================
echo Done
echo ============================================================
echo.
echo Press any Key to Exit.
pause >nul
exit
