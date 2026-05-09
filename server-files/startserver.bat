@echo off
REM Zephyr's Wake — NeoForge Server Bootstrap & Start Script
REM Downloads the NeoForge installer, installs the server, accepts EULA, and starts.
REM Usage: startserver.bat [MEMORY]
REM   MEMORY defaults to 4G if not set.

set NEOFORGE_VERSION=21.1.228
set INSTALLER_JAR=neoforge-%NEOFORGE_VERSION%-installer.jar
set ARGS_FILE=libraries\net\neoforged\neoforge\%NEOFORGE_VERSION%\win_args.txt

set MEMORY=%1
if "%MEMORY%"=="" set MEMORY=4G

REM --- Install NeoForge if needed ---
if not exist "%ARGS_FILE%" (
    echo NeoForge server not installed. Installing...

    if not exist "%INSTALLER_JAR%" (
        echo Downloading NeoForge %NEOFORGE_VERSION% installer...
        curl -fLO "https://maven.neoforged.net/releases/net/neoforged/neoforge/%NEOFORGE_VERSION%/neoforge-%NEOFORGE_VERSION%-installer.jar"
        if errorlevel 1 (
            echo Failed to download installer. Ensure curl is available or download manually.
            pause
            exit /b 1
        )
    )

    echo Running NeoForge installer...
    java -jar "%INSTALLER_JAR%" --installServer
    if errorlevel 1 (
        echo NeoForge installation failed.
        pause
        exit /b 1
    )
    echo NeoForge installed successfully.
)

REM --- Accept EULA ---
if not exist "eula.txt" (
    echo eula=true> eula.txt
    echo EULA accepted.
)

REM --- Start server ---
echo Starting Zephyr's Wake server with %MEMORY% memory...

java ^
  -Xms%MEMORY% -Xmx%MEMORY% ^
  -XX:+UseG1GC ^
  -XX:+ParallelRefProcEnabled ^
  -XX:MaxGCPauseMillis=200 ^
  -XX:+UnlockExperimentalVMOptions ^
  -XX:+DisableExplicitGC ^
  -XX:G1NewSizePercent=30 ^
  -XX:G1MaxNewSizePercent=40 ^
  -XX:G1HeapRegionSize=8M ^
  -XX:G1ReservePercent=20 ^
  -XX:G1HeapWastePercent=5 ^
  -XX:G1MixedGCCountTarget=4 ^
  -XX:InitiatingHeapOccupancyPercent=15 ^
  -XX:G1MixedGCLiveThresholdPercent=90 ^
  -XX:G1RSetUpdatingPauseTimePercent=5 ^
  -XX:SurvivorRatio=32 ^
  -XX:+PerfDisableSharedMem ^
  -XX:MaxTenuringThreshold=1 ^
  -Dusing.aikars.flags=https://mcflags.emc.gs ^
  -Daikars.new.flags=true ^
  @%ARGS_FILE% ^
  nogui
pause
