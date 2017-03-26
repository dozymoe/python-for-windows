@ECHO off
@SETLOCAL

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | FIND /i "x86" > NUL && SET OS_ARCH=x86 || SET OS_ARCH=x64
for /f "tokens=4-5 delims=. " %%i in ('ver') do SET OS_VER=%%i.%%j


if not exist "C:\ProgramData\chocolatey\bin\choco.exe" (
    if "%OS_VER%" == "6.1" (
        REM Windows 7

        ECHO We need PowerShell v4 to install Chocolatey
        ECHO And PowerShell v4 needs at least dotnet v4.5
        ECHO.

        ECHO Install dotnet v4.5
        %~dp0\vendor\dotnetfx45_full_x86_x64.exe /q /norestart
        if %errorlevel% lss 0 (
            ECHO Unable to install dotnet 4.5
            PAUSE
            exit /b %errorlevel%
        )
        ECHO.

        ECHO Install KB2819745
        wusa.exe /quiet %~dp0\vendor\PowerShell4-Windows6.1-KB2819745-%OS_ARCH%-MultiPkg.msu
        if %errorlevel% neq 0 (
            ECHO Unable to install PowerShell v4
            PAUSE
            exit /b %errorlevel%
        )
        ECHO.

        ECHO Install KB2533623
        wusa.exe /quiet %~dp0\vendor\Windows6.1-KB2533623-%OS_ARCH%.msu
        if %errorlevel% neq 0 (
            ECHO Unable to install KB2533623
            PAUSE
            exit /b %errorlevel%
        )
        ECHO.
    )

    ECHO Install Chocolatey
    powershell -ExecutionPolicy Unrestricted -Command "Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | iex"
    if %errorlevel% lss 0 (
        ECHO Unable to install Chocolatey.
        PAUSE
        exit /b %errorlevel%
    )
    ECHO.

    SET PATH=C:\ProgramData\chocolatey\bin;%PATH%
)

ECHO Lower PowerShell execution policy, needed by NuGet.
ECHO Won't work though, you need to run gpedit.msc.
ECHO.

reg Add "HKLM\SOFTWARE\Policies\Microsoft\Windows\PowerShell" /f /v "EnableScripts" /t REG_DWORD /d 1
if %errorlevel% neq 0 (
    ECHO Unable to lower PowerShell execution policy.
    PAUSE
    exit /b %errorlevel%
)
ECHO.


if "%OS_VER%" == "6.3" (
    REM Windows 8.1

    ECHO Install Windows 10 Universal CRT
    wusa.exe /quiet %~dp0\vendor\Windows8.1-KB2999226-%OS_ARCH%.msu
    if %errorlevel% neq 0 (
        ECHO Unable to install Windows 10 Universal CRT
        PAUSE
        exit /b %errorlevel%
    )
)
ECHO.

ECHO Install python v3
choco install -y python3
if %errorlevel% neq 0 (
    ECHO Unable to install Python3.
    PAUSE
    exit /b %errorlevel%
)
SET PATH=C:\Python36;%PATH%
ECHO.

ECHO Install git
choco install -y git.install
if %errorlevel% neq 0 (
    ECHO Unable to install Git for CommandLine.
    PAUSE
    exit /b %errorlevel%
)
ECHO.

ECHO Success!
PAUSE
